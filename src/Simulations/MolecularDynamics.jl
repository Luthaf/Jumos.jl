# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                              Molecular dynamics
# ============================================================================ #

export MolecularDynamics
export set_integrator!, getforces!

include("forces.jl")

abstract BaseIntegrator
abstract BaseControl
abstract BaseCheck

type MolecularDynamics <: Propagator
    # MD algorithms
    integrator      :: BaseIntegrator
    controls        :: Vector{BaseControl}
    checks          :: Vector{BaseCheck}
    compute_forces  :: BaseForcesComputer
    # MD data cache
    forces          :: Array3D{Float64}
end

# This define the default values for a simulation !
function MolecularDynamics(integrator=VelocityVerlet(1.0))
    controls = BaseControl[]
    checks = BaseCheck[]
    forces = Array3D(Float64, 0)
    return MolecularDynamics(integrator, controls, checks, NaiveForces(), forces)
end

# Convenient method.
MolecularDynamics(timestep::Real) = MolecularDynamics(VelocityVerlet(timestep))

# Algorithms for molecular dynamics
include("MolecularDynamics/integrators.jl")
include("MolecularDynamics/control.jl")
include("MolecularDynamics/check.jl")

include("MolecularDynamics/initial_velocities.jl")

function setup(sim::Simulation{MolecularDynamics}, universe::Universe)
    get_masses!(universe)
    check_masses(universe)

    setup(sim.propagator.integrator, sim, universe)
    for control in sim.propagator.controls
        setup(control, sim)
    end
end

function Base.call(md::MolecularDynamics, universe::Universe)
    integrate!(md, universe)
    control!(md, universe)
    check!(md, universe)
    return nothing
end

@doc "
Integrate the equations of motion
" ->
function integrate!(md::MolecularDynamics, universe::Universe)
    md.integrator(md, universe)
end

@doc "
Control a parameter in simulation like temperature or presure or volume, …
" ->
function control!(md::MolecularDynamics, universe::Universe)
    for callback in md.controls
        callback(md, universe)
    end
end

@doc "
Check the physical consistency of the simulation : number of particles is
constant, global velocity is zero, …
" ->
function check!(md::MolecularDynamics, universe::Universe)
    for callback in md.checks
        callback(md, universe)
    end
end

function getforces!(md::MolecularDynamics, universe::Universe)
    md.compute_forces(universe, md.forces)
end

# ============================================================================ #

function Base.push!(sim::Simulation{MolecularDynamics}, control::BaseControl)
    if !ispresent(sim, control)
        push!(sim.controls, control)
    else
        warn("$control is aleady present in this simulation")
    end
    return sim.controls
end

function Base.push!(sim::Simulation{MolecularDynamics}, check::BaseCheck)
    if !ispresent(sim, check)
        push!(sim.checks, check)
    else
        warn("$check is aleady present in this simulation")
    end
    return sim.checks
end

function ispresent(sim::Simulation{MolecularDynamics}, algo::Union(BaseCheck, BaseControl))
    algo_type = typeof(algo)
    for field in [:checks, :controls]
        for elem in getfield(sim.propagator, field)
            if isa(elem, algo_type)
                return true
            end
        end
    end
    return false
end

function set_integrator!(sim::Simulation{MolecularDynamics}, integrator::BaseIntegrator)
    sim.propagator.integrator = integrator
end
