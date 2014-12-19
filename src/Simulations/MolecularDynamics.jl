# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                   Molecular dynamic simulations
# ============================================================================ #

import Base: show
export MolecularDynamic, run!

abstract Simulation
abstract BaseForcesComputer
abstract BaseIntegrator
abstract BaseEnforce
abstract BaseCheck
abstract BaseCompute
abstract BaseOutput

include("MD/potentials.jl")

typealias Interactions Dict{(Integer, Integer), Potential}

type SimulationConfigurationError <: Exception
    msg :: String
end
export SimulationConfigurationError

function show(io::IO, e::SimulationConfigurationError)
    print(io, "Simulation Configuration Error : \n")
    print(io, e.msg)
end

type MolecularDynamic <: Simulation
    # Algorithms
    interactions    :: Interactions
    forces_computer :: BaseForcesComputer
    integrator      :: BaseIntegrator
    enforces        :: Vector{BaseEnforce}
    checks          :: Vector{BaseCheck}
    computes        :: Vector{BaseCompute}
    outputs         :: Vector{BaseOutput}
    # Data
    topology        :: Topology
    cell            :: UnitCell
    frame           :: Frame
    masses          :: Vector{Float64}
    forces          :: Array3D{Float64}
    # all other data to be shared
    data            :: Dict{Symbol, Any}
end

# This define the default values for a simulation !
function MolecularDynamic(integrator=VelocityVerlet(1.0))
    interactions = Interactions()
    forces_computer = NaiveForces()

    enforces = BaseEnforce[WrapParticles()]
    checks = BaseCheck[AllPositionsAreDefined(), ]
    computes = BaseCompute[]
    outputs = BaseOutput[]

    topology = Topology()
    cell = UnitCell()
    masses = Float64[]
    forces = Array3D(Float64, 0)
    frame = Frame(topology)
    data = Dict(:frame => frame)

    return MolecularDynamic(interactions,
                        forces_computer,
                        integrator,
                        enforces,
                        checks,
                        computes,
                        outputs,
                        topology,
                        cell,
                        frame,
                        masses,
                        forces,
                        data
                        )
end

# Convenient method.
MolecularDynamic(timestep::Real) = MolecularDynamic(VelocityVerlet(timestep))


include("MD/forces.jl")
include("MD/integrators.jl")
include("MD/enforce.jl")
include("MD/check.jl")
include("MD/compute.jl")
include("MD/output.jl")
include("MD/initial_velocities.jl")


@doc "
`run!(sim::MolecularDynamic, nsteps::Integer)`

Run a Molecular Dynamics simulation for nsteps steps.
" ->
function run!(sim::MolecularDynamic, nsteps::Integer)

    sim.masses = atomic_masses(sim.topology)

    check_settings(sim)

    for i=1:nsteps
        integrate(sim)
        enforce(sim)
        check(sim)
        compute(sim)
        output(sim)
        sim.frame.step += 1
    end
    return nothing
end

@doc "
`check_settings(sim::MolecularDynamic)`

Check that the simulation is consistent, and that every information has been
set by the user.
" ->
function check_settings(sim::MolecularDynamic)
    check_interactions(sim)
    check_masses(sim)
    setup_outputs(sim)
end

function check_interactions(sim::MolecularDynamic)
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

function check_masses(sim::MolecularDynamic)
    if countnz(sim.masses) != size(sim.topology)
        bad_masses = Set()
        for (i, val) in enumerate(sim.masses)
            if val == 0.0
                union!(bad_masses, [sim.topology[i].name])
            end
        end
        missing = join(bad_masses, " ")
        throw(SimulationConfigurationError(
                "Missing masses for the following atomic types: $missing"
            ))
    end
end

function setup_outputs(sim::MolecularDynamic)
    for output in sim.outputs
        setup(output, sim)
    end
end

@doc "
Integrate the equations of motion
" ->
function integrate(sim::MolecularDynamic)
    sim.integrator(sim)
end

function get_forces!(sim::MolecularDynamic)
    sim.forces = sim.forces_computer(sim.forces, sim.frame, sim.interactions)
end

@doc "
Enforce a parameter in simulation like temperature or presure or volume, …
" ->
function enforce(sim::MolecularDynamic)
    for callback in sim.enforces
        callback(sim.frame)
    end
end

@doc "
Check the physical consistency of the simulation : number of particles is
constant, global velocity is zero, …
" ->
function check(sim::MolecularDynamic)
    for callback in sim.checks
        callback(sim)
    end
end


@doc "
Compute values of interest : temperature, total energy, radial distribution
functions, diffusion coefficients, …
" ->
function compute(sim::MolecularDynamic)
    for callback in sim.computes
        callback(sim)
    end
end

@doc "Output data to files : trajectories, energy as function of time, …
" ->
function output(sim::MolecularDynamic)
    context = sim.data
    context[:step] = sim.frame.step
    for out in sim.outputs
        if out.current == out.frequency
            write(out, context)
            out.current = 0
        else
            out.current += 1
        end
    end
end

include("UI.jl")
