#===============================================================================
        Some functions for computing radial distribution functions
===============================================================================#
import Base: write
export RDF

type RDF
    values::Histogram{Float64}
    atom_i::String
    atom_j::String
    used_steps::Int
    n_parts::BigInt
    box::SimBox
end

function RDF(atom_i::String, atom_j::String; bins=200)
    h = Histogram(Float64, bins)
    return RDF(h, atom_i, atom_j, 0, 0, SimBox())
end

RDF(atom_i::String; kwargs...) = RDF(atom_i, atom_i; kwargs...)

function update!(r::RDF, f::Frame)
    const natoms = length(f.positions)
    distances = Array(Float64, natoms, natoms)
    distance_array(f, f, distances)

    dists = Float64[]

    for i=1:natoms
        if f.topology.atoms[i].name == r.atom_i
            r.n_parts += 1
            for j=(i+1):natoms
                if f.topology.atoms[j].name == r.atom_j
                    push!(dists, distances[i, j])
                end
            end
        end
    end

    if r.box == SimBox(0.0) initialize!(r, f) end

    update!(r.values, dists, weight=2.0)
    r.used_steps += 1
    return nothing
end

function initialize!(r::RDF, f::Frame)
    @assert f.box != SimBox(0.0) "The simulation box can not be null for RDF computations"
    r.box = f.box
    r.values.min = 0.0
    r.values.max = 0.5*min(r.box.length[1], r.box.length[2], r.box.length[3])
end

function write(r::RDF, trajname::String; outname="")
    if outname == ""
        outname = join(split(trajname, '.')[1:end-1], '.')
        outname = "$outname-$(r.atom_i)-$(r.atom_j).rdf"
    end
    f = open(outname, "w")
    println(f, "# Radial distribution function for atoms ", r.atom_i, " & ",
                r.atom_j, " for trajectory", trajname)
    for i=1:r.values.bins
        position = i*r.values.step
        println(f, position, "\t", r.values.weight[i])
    end
    close(f)
    return outname
end

function normalize!(r::RDF)
    function norm(i::Integer)
        V = r.box[1]*r.box[2]*r.box[3]
        n_particles = r.n_parts/(r.used_steps)
        rho = n_particles/V
        dr = r.values.step
        f = j -> 4*pi/3 * (dr*(j + 1))^3
        return rho * n_particles * r.used_steps * (f(i+1) - f(i))
    end

    normalize!(r.values, norm)
end

function clean!(r::RDF)
    clean!(r.values)
    r.used_steps = 0
    return nothing
end
