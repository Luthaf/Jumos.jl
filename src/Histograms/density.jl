#===============================================================================
   This file implement some functions for computing a density profile
===============================================================================#

type DensityProfile
    values::Histogram
    atom::String
    dim::Int  # The dimension for computing the profile
    used_steps::Int
end

function DensityProfile(atom::String, dim::Int;
                        bins=300, min=0, max=0, step=0)
    h = Histogram(Float64, bins; min=min, max=max, step=step)
    return DensityProfile(h, atom, dim, 0)
end

function update!(d::DensityProfile, f::Frame)
    positions = Float64[]
    for (i, pos) in enumerate(f.positions[d.dim, :])
        if f.trajectory.topology.atoms[i].name == d.atom
            # PBC
            pos -= floor(pos/f.box[d.dim])*f.box[d.dim]
            push!(positions, pos)
        end
    end
    V = f.box[1] * f.box[2] * f.box[3]
    update!(d.values, positions; weight=1/V)
    d.used_steps += 1
    return nothing
end

function write(d::DensityProfile, filename::String)
    outname = join(split(filename, '.')[1:end-1], '.')
    outname = "$outname-$(d.atom).rho"
    f = open(outname, "w")
    println(f, "# Density profile along dimmension ", d.dim, " for trajectory", filename)
    println(f, "# x[", d.dim, "]\trho")
    for i=1:d.values.bins
        position = i*d.values.step
        println(f, position, "\t", d.values.weight[i])
    end
    close(f)
    return outname
end

function normalize!(d::DensityProfile)
    return normalize!(d.values, 1e-4*d.used_steps)
end


function clean!(d::DensityProfile)
    clean!(d.values)
    d.used_steps = 0
    return nothing
end
