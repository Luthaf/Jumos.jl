# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                    Checking the simulation consistency
# ============================================================================ #

export Check
export GlobalVelocityIsNull, TotalForceIsNull, AllPositionsAreDefined
# abstract Check -> Defined in MolecularDynamics.jl

type CheckError <: Exception
    msg :: String
end
export CheckError

function Base.call(io::IO, e::CheckError)
    print(io, "Error in simulation : \n")
    print(io, e.msg)
end


@doc "
Check if all the positions and all the velocities are number : not NaN neither Inf.
" ->
immutable AllPositionsAreDefined <: Check end

function Base.call(::AllPositionsAreDefined, univ::Universe, ::MolecularDynamics)
    const natoms = size(univ.frame)
    for i=1:natoms, dim=1:3
        isfinite(univ.frame.positions[dim, i]) || throw(CheckError(
            "Lost atom at step $(sim.frame.step): atom n° $i
                (position not defined)"
        ))
    end
    for i=1:natoms, dim=1:3
        isfinite(univ.frame.velocities[dim, i]) || throw(CheckError(
            "Lost atom at step $(sim.frame.step): atom n° $i.
                (velocity not defined)"
        ))
    end
end


@doc "
Check if the overall velocity is null, with a 1e-5 tolerance.
" ->
immutable GlobalVelocityIsNull <: Check end

function Base.call(::GlobalVelocityIsNull, univ::Universe, ::MolecularDynamics)
    const natoms = size(univ.frame)
    V = 0.0
    for i=1:natoms, j=1:3
        V += univ.frame.velocities[j, i]
    end
    isapprox(V, 0.0, atol=1e-5) || throw(CheckError(
        "The global velocity is not null."
    ))
end


@doc "
Check if the sum of the forces is effectively null, with a 1e-5 tolerance.
" ->
immutable TotalForceIsNull <: Check end

function Base.call(::TotalForceIsNull, univ::Universe, propag::MolecularDynamics)
    const natoms = size(univ.frame)
    F = 0.0
    for i=1:natoms, dim=1:3
        F += propag.forces[dim, i]
    end
    isapprox(F, 0.0, atol=1e-5) || throw(CheckError(
        "The global force is not null."
    ))
end
