#===============================================================================
            Types for forces evaluations against all particles
                Pair list algorithm, Ewalds summation, ...
===============================================================================#

abstract BaseForcesComputer

# Naive forces computation : just get the vector between two particles, and
# call the potential for these particles.
type NaiveForces <: BaseForcesComputer
end

function call(::NaiveForces, data::Frame, interactions::Vector{Interaction})
    r = Vect3D()
    @inbounds for i=1:size(data)
        data.forces[i] = vect3d(0.0)
    end
    const natoms = size(data)
    @inbounds for i=1:(natoms-1), j=i:natoms
            r = particle_distance(data, i, j)
            r = r ./ norm(r)
            potential = interactions[(i, j)]
            data.forces[i] += r .* forces(potential, norm(r))
            data.forces[j] -= r .* forces(potential, norm(r))
    end
end
