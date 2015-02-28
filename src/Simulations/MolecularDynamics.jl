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
export set_integrator!

abstract BaseIntegrator
abstract BaseControl
abstract BaseCheck

immutable MolecularDynamics <: Propagator
    # MD algorithms
    integrator      :: BaseIntegrator
    controls        :: Vector{BaseControl}
    checks          :: Vector{BaseCheck}
    # MD data cache
    forces          :: Array3D{Float64}
end

# This define the default values for a simulation !
function MolecularDynamics(integrator=VelocityVerlet(1.0))
    controls = BaseControl[WrapParticles()]
    checks = BaseCheck[AllPositionsAreDefined(), ]
    forces = Array3D(Float64, 0)
    return MolecularDynamics(integrator, controls, checks, forces)
end

# Convenient method.
MolecularDynamics(timestep::Real) = MolecularDynamics(VelocityVerlet(timestep))

# Algorithms for molecular dynamics
include("MolecularDynamics/integrators.jl")
include("MolecularDynamics/control.jl")
include("MolecularDynamics/check.jl")

include("MolecularDynamics/initial_velocities.jl")

function setup(MD::MolecularDynamics, universe::Universe)
    get_masses!(universe)

    check_settings(MD)
    setup(MD.integrator, universe)
    for control in MD.controls
        setup(control, MD)
    end
end

@doc "
`propagate(sim::Simulation, frame::Frame)`

Run a Molecular Dynamics simulation for nsteps steps.
" ->
function propagate(sim::Simulation, frame::Frame)
    integrate(sim)
    control(sim)
    check(sim)
    return nothing
end

@doc "
Integrate the equations of motion
" ->
function integrate(sim::Simulation)
    sim.integrator(sim)
end

@doc "
Control a parameter in simulation like temperature or presure or volume, …
" ->
function control(sim::Simulation)
    for callback in sim.controls
        callback(sim)
    end
end

@doc "
Check the physical consistency of the simulation : number of particles is
constant, global velocity is zero, …
" ->
function check(sim::Simulation)
    for callback in sim.checks
        callback(sim)
    end
end

# ============================================================================ #

function Base.push!(sim::Simulation, control::BaseControl)
    assert(isa(sim.propagator, MolecularDynamics),
           "We can only add controls to a MolecularDynamics Simulation.")
    if !ispresent(sim, control)
        push!(sim.controls, control)
    else
        warn("$control is aleady present in this simulation")
    end
    return sim.controls
end

function Base.push!(sim::Simulation, check::BaseCheck)
    assert(isa(sim.propagator, MolecularDynamics),
           "We can only add checks to a MolecularDynamics Simulation.")
    if !ispresent(sim, check)
        push!(sim.checks, check)
    else
        warn("$check is aleady present in this simulation")
    end
    return sim.checks
end

function ispresent(sim::Simulation, algo::Union(BaseCheck, BaseControl))
    algo_type = typeof(algo)
    for field in [:outputs, :controls]
        for elem in getfield(sim, field)
            if isa(elem, algo_type)
                return true
            end
        end
    end
    return false
end

function set_integrator!(sim::Simulation, integrator::BaseIntegrator)
    assert(isa(sim.propagator, MolecularDynamics),
           "We can only set integrator for MolecularDynamics Simulation.")
    sim.integrator = integrator
end

# ============================================================================ #

@doc "
`check_settings(sim::Simulation)`

Check that the simulation is consistent, and that every information has been
set by the user.
" ->
function check_settings(sim::Simulation)
    check_interactions(sim)
    check_masses(sim)
end

function check_interactions(sim::Simulation)
    # REDO
    atomic_types = sim.topology.atom_types

    atomic_pairs = Set{(Integer, Integer)}()
    for (i, j) in keys(sim.interactions)
        union!(atomic_pairs, [(i, j)])
    end

    all_atomic_pairs = Set{(Integer, Integer)}()
    ntypes = size(atomic_types, 1)
    for i=1:ntypes, j=1:ntypes
        union!(all_atomic_pairs, [(i, j), (j, i)])
    end
    setdiff!(all_atomic_pairs, atomic_pairs)
    if length(all_atomic_pairs) != 0
        missings = ""
        for (i, j) in all_atomic_pairs
            missings *= (string(atomic_types[i].name) * " - " *
                         string(atomic_types[j].name) * "\n")
        end
        throw(SimulationConfigurationError(
            "The following atom pairs do not have any interaction:

            $missings
            "
        ))
    end
end
