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

abstract Propagator
abstract BaseCompute
abstract BaseOutput

type Simulation{T<:Propagator}
    # Algorithms
    propagator      :: Propagator
    computes        :: Vector{BaseCompute}
    outputs         :: Vector{BaseOutput}
end

include("potentials.jl")
# abstract Interaction -> In the Universe module
immutable PairInteraction <: Interaction
    i::UInt64
    j::UInt64
    potential::PotentialComputation
end

immutable Interaction3Body <: Interaction
    i::UInt64
    j::UInt64
    potential::PotentialComputation
end

immutable PairInteraction <: Interaction
    i::UInt64
    j::UInt64
    potential::PotentialComputation
end

include("forces.jl")
include("compute.jl")
include("output.jl")

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

include("MolecularDynamics.jl")
include("UI.jl")
