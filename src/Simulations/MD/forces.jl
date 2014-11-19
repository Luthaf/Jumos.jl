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
    r = vect3d()
    natoms = size(frame)

    if size(forces, 1) != natoms
        resize!(forces, natoms)
    end

    @inbounds for i=1:natoms
        forces[i] = vect3d(0.0)
    end

    @inbounds for i=1:(natoms-1), j=i:natoms
        r = distance3d(frame, i, j)
        r = normalize(r)
        atom_i = frame.topology.atoms[i]
        atom_j = frame.topology.atoms[j]
        potential = interactions[(atom_i, atom_j)]
        forces[i] += r * force(potential, norm(r))
        forces[j] -= r * force(potential, norm(r))
    end
end
