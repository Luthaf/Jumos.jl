#===============================================================================
        Some functions for computing radial distribution functions
===============================================================================#

type RDF
    values::Histogram
    atom_i::String
    atom_j::String
    used_steps::Int
end

function RDF(atom_i::String, atom_j::String; bins=300, min=0, max=0, step=0)
    h = Histogram(Float64, bins; min=min, max=max, step=step)
    return RDF(h, atom_i, atom_j, 0)
end

RDF(atom_i::String; kwargs...) = RDF(atom_i, atom_i; kwargs...)

function update!(r::RDF, f::Frame)
    const natoms = length(f.positions)
    distances = Array(Float64, natoms, natoms)
    distance_array(f, f, distances)

    dists = Float64[]

    for i=1:natoms
        if f.topology.atoms[i].name == r.atom_i
            for j=1:natoms
                if f.topology.atoms[j].name == r.atom_j
                    push!(dists, distances[i, j])
                end
            end
        end
    end

    update!(r.values, dists)
    r.used_steps += 1
    return nothing
end

function write(d::DensityProfile, filename::String)
    #TODO
end

function normalize!(d::DensityProfile)
    #TODO
end


function clean!(d::DensityProfile)
    clean!(d.values)
    d.used_steps = 0
    return nothing
end
