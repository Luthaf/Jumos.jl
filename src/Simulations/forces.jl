# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                Forces evaluations against all particles.
# ============================================================================ #

export ForcesComputer, NaiveForces
abstract ForcesComputer

# ============================================================================ #

@doc "
Naive forces computation : just get the vector between two particles, and
call the force function for these particles.
"->
immutable NaiveForces <: ForcesComputer end

function Base.call(::NaiveForces, univ::Universe, forces::Array3D)
    interactions = univ.interactions
    const natoms = size(univ)

    # Temporary values
    r = Array(Float64, 3)
    dist = 0.0
    f = 0.0
    potential = NullPotential()

    if length(forces) != natoms
        # Allocating new memory as needed
        resize!(forces, natoms)
    end
    fill!(forces, 0)

    for i=1:(natoms-1)
        itype = univ.topology.atoms[i]
        for j=(i+1):natoms

            jtype = univ.topology.atoms[j]
            r = distance3d(univ, i, j)
            dist = norm(r)
            unit!(r)

            for pot in pairs(interactions, itype, jtype)
                f = force(pot, dist)
                @simd for dim=1:3
                    @inbounds r[dim] *= f
                end

                @simd for dim=1:3
                    @inbounds forces[dim, i] += -r[dim]
                    @inbounds forces[dim, j] += r[dim]
                end
            end

            #TODO add bonds, angles and so on.
        end
    end
    return forces
end
