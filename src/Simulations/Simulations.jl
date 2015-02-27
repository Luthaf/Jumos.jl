# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                           Base Simulation type
# ============================================================================ #

export propagate!
export Simulation, Propagator

abstract Propagator
abstract BaseCompute
abstract BaseOutput

type Simulation
    # Algorithms
    propagator      :: Propagator
    computes        :: Vector{BaseCompute}
    outputs         :: Vector{BaseOutput}
end

Simulation(p::Propagator) = Simulation(p, BaseCompute[], BaseOutput[])

function Simulation(propagator::Symbol, args...)
    if propagator == :MD || propagator == :md || propagator == :moleculardynamics
        p = MolecularDynamics(args...)
    else
        throw(JumosError("Unknown propagator in simulation: $propagator."))
    end
    return Simulation(p)
end

include("forces.jl")
include("compute.jl")
include("output.jl")

type SimulationConfigurationError <: Exception
    msg :: String
end
export SimulationConfigurationError

function show(io::IO, e::SimulationConfigurationError)
    print(io, "Simulation Configuration Error : \n")
    print(io, e.msg)
end

# TODO: check initial consistency of a simulation.

@doc "
`propagate!(simulation, universe, nsteps)`

Propagate a Simulation for `nsteps` steps on the `universe`.
" ->
function propagate!(sim::Simulation, universe::Universe, nsteps::Integer)

    for output in sim.outputs
        setup(output, sim)
    end

    setup(sim.propagator, universe)

    for i=1:nsteps
        sim.propagator(universe)
        compute(sim, universe)
        output(sim, universe)
        universe.frame.step += 1
        universe.data[:step] = universe.frame.step
    end
    return nothing
end

@doc "
Compute values of interest : temperature, total energy, radial distribution
functions, diffusion coefficients, …
" ->
function compute(sim::Simulation, universe::Universe)
    for callback in sim.computes
        callback(universe)
    end
end

@doc "
Output data to files : trajectories, energy as function of time, …
" ->
function output(sim::Simulation, universe::Universe)
    context = universe.data
    for out in sim.outputs
        step(out)
        if done(out)
            write(out, context)
        end
    end
end

function Base.push!(sim::Simulation, output::BaseOutput)
    if !ispresent(sim, output)
        push!(sim.outputs, output)
    else
        warn("$output is aleady present in this simulation")
    end
    return sim.outputs
end

function Base.push!(sim::Simulation, compute::BaseCompute)
    if !ispresent(sim, compute)
        push!(sim.computes, compute)
    else
        warn("$compute is aleady present in this simulation")
    end
    return sim.computes
end

function ispresent(sim::Simulation, algo::Union(BaseCompute, BaseOutput))
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
