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

function call(::NaiveForces, forces::Array3D, data::Frame, interactions::Vector{Interaction})

    # Temporary vector
    r = Vect3D()

    if size(forces, 1) != size(data)
        resize!(forces, size(data))
    end

    @inbounds for i=1:size(data)
        forces[i] = vect3d(0.0)
    end
    const natoms = size(data)
    @inbounds for i=1:(natoms-1), j=i:natoms
            r = particle_distance(data, i, j)
            r = normalize(r)
            potential = interactions[(i, j)]
            forces[i] += r .* forces(potential, norm(r))
            forces[j] -= r .* forces(potential, norm(r))
    end
end
