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
    r = Vect3D()
    natoms = size(frame)

    if size(forces, 1) != natoms
        resize!(forces, natoms)
    end

    @inbounds for i=1:natoms
        forces[i] = vect3d(0.0)
    end

    @inbounds for i=1:(natoms-1), j=i:natoms
            r = particle_distance(frame, i, j)
            r = normalize(r)
            potential = interactions[(i, j)]
            forces[i] += r .* forces(potential, norm(r))
            forces[j] -= r .* forces(potential, norm(r))
    end
end
