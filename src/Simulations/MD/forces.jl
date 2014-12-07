#===============================================================================
            Types for forces evaluations against all particles
                Pair list algorithm, Ewalds summation, ...
===============================================================================#
export BaseForcesComputer, NaiveForces
abstract BaseForcesComputer

function force_array_to_internal!(a::Array3D)
    for i=1:3
        for j=1:length(a)
            a.data[i, j] *= 1e-4
        end
    end
    return a
end

@doc "
Naive forces computation : just get the vector between two particles, and
call the force function for these particles.
"->
type NaiveForces <: BaseForcesComputer
end

function call(::NaiveForces, forces::Array3D, frame::Frame, interactions::Interactions)

    # Temporary vector
    r = Array(Float32, 3)
    natoms = size(frame)
    dist = 0.0

    if length(forces) != natoms
        # Allocating new memory as needed
        forces = resize(forces, natoms)
    end

    @inbounds for i=1:natoms
        forces[i] = zeros(Float32, 3)
    end

    @inbounds for i=1:natoms, j=(i+1):natoms
        r = distance3d(frame, i, j)
        dist = norm(r)
        unit!(r)
        atom_i = frame.topology.atoms[i]
        atom_j = frame.topology.atoms[j]
        potential = interactions[(atom_i, atom_j)]
        r *= force(potential, dist)

        forces[i] .+= -r
        forces[j] .+= r
    end
    force_array_to_internal!(forces)
    return forces
end
