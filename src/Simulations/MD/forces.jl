# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                Forces evaluations against all particles.
# ============================================================================ #

export BaseForcesComputer, NaiveForces

# abstract BaseForcesComputer -> Defined in MolecularDynamics.jl

# TODO: More thought about this
function force_array_to_internal!(a::Array3D)
    for i=1:3
        for j=1:length(a)
            a.data[i, j] *= 1e-4
        end
    end
    return a
end

function get_potential(interactions::Interactions, topology::Topology, i::Integer, j::Integer)
    atom_i = topology.atoms[i]
    atom_j = topology.atoms[j]
    return interactions[(atom_i, atom_j)]
end

@doc "
Naive forces computation : just get the vector between two particles, and
call the force function for these particles.
"->
immutable NaiveForces <: BaseForcesComputer end

function call(::NaiveForces, forces::Array3D, frame::Frame, interactions::Interactions)

    natoms = size(frame)

    # Temporary values
    r = Array(Float64, 3)
    dist = 0.0
    f = 0.0
    potential = NullPotential()

    if length(forces) != natoms
        # Allocating new memory as needed
        forces = resize(forces, natoms)
    end

    @inbounds for i=1:natoms
        forces[i] = zeros(Float64, 3)
    end

    @inbounds for i=1:(natoms-1), j=(i+1):natoms
        r = distance3d(frame, i, j)
        dist = norm(r)
        unit!(r)
        potential = get_potential(interactions, frame.topology, i, j)
        f = force(potential, dist)
        for dim=1:3
            r[dim] *= f
        end

        for dim=1:3
            forces[dim, i] += -r[dim]
        end

        for dim=1:3
            forces[dim, j] += r[dim]
        end
    end
    return force_array_to_internal!(forces)
end
