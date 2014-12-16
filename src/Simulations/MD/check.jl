# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                    Checking the simulation consistency
# ============================================================================ #

import Base: show, call
export BaseCheck
export ParticleNumberIsConstant, GlobalVelocityIsNull, TotalForceIsNull
# abstract BaseCheck -> Defined in MolecularDynamics.jl

function show(io::IO, a::BaseCheck)
    show(io, typeof(a))
end

type CheckError <: Exception
    msg :: String
end
export CheckError

function show(io::IO, e::CheckError)
    print(io, "Error in simulation : \n")
    print(io, e.msg)
end


@doc "
Check if all the positions and all the velocities are number : not NaN neither Inf.
" ->
type AllPositionsAreDefined <: BaseCheck
end

function call(::AllPositionsAreDefined, sim::MDSimulation)
    const natoms = size(sim.frame)
    for i=1:natoms, j=1:3
        isfinite(sim.frame.positions[j, i]) || throw(CheckError(
            "All positions are not defined."
        ))
    end
    for i=1:natoms, j=1:3
        isfinite(sim.frame.velocities[j, i]) || throw(CheckError(
            "All velocities are not defined."
        ))
    end
end


@doc "
Check if the overall velocity is null, with a 1e-5 tolerance.
" ->
type GlobalVelocityIsNull <: BaseCheck
end

function call(::GlobalVelocityIsNull, sim::MDSimulation)
    const natoms = size(sim.frame)
    V = 0.0
    for i=1:natoms, j=1:3
        V += sim.frame.velocities[j, i]
    end
    isapprox(V, 0.0, atol=1e-5) || throw(CheckError(
        "The global velocity is not null."
    ))
end


@doc "
Check if the sum of the forces is effectively null, with a 1e-5 tolerance.
" ->
type TotalForceIsNull <: BaseCheck
end

function call(::TotalForceIsNull, sim::MDSimulation)
    const natoms = size(sim.frame)
    F = 0.0
    for i=1:natoms, j=1:3
        F += sim.forces[j, i]
    end
    isapprox(F, 0.0, atol=1e-5) || throw(CheckError(
        "The global force is not null."
    ))
end
