#===============================================================================
            Types for forces evaluations against all particles
                Pair list algorithm, Ewalds summation, ...
===============================================================================#
export BaseForcesComputer, NaiveForces
abstract BaseForcesComputer

# Naive forces computation : just get the vector between two particles, and
# call the potential for these particles.
type NaiveForces <: BaseForcesComputer
end

function call(::NaiveForces, forces::Array3D, frame::Frame, interactions::Interactions)

    # Temporary vector
    r = Vector(Float32, 3)
    natoms = size(frame)

    if size(forces, 1) != natoms
        resize!(forces, natoms)
    end

    @inbounds for i=1:natoms
        forces[i] = zeros(Float32, 3)
    end

    @inbounds for i=1:natoms, j=(i+1):natoms
        r = distance3d(frame, i, j)
        r = normalize(r)
        atom_i = frame.topology.atoms[i]
        atom_j = frame.topology.atoms[j]
        potential = interactions[(atom_i, atom_j)]

        r *= force(potential, norm(r))
        forces[i] += r
        forces[j] -= r
    end
end
