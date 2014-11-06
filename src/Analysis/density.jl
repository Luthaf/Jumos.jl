#===============================================================================
   This file implement some functions for computing a density profile
===============================================================================#

import Base: write
export DensityProfile

type DensityProfile
    values::Histogram{Float64}
    atom::String
    dim::Int  # The dimension for computing the profile
    used_steps::Int
end

function DensityProfile(atom::String, dim::Int;
                        bins=300, min=0, max=0, step=0)
    hist = Histogram(Float64, bins; min=min, max=max, step=step)
    return DensityProfile(hist, atom, dim, 0)
end

function update!(density::DensityProfile, frame::Frame)
    positions = Float64[]
    for (i, pos) in enumerate(frame.positions)
        if frame.topology.atoms[i].name == density.atom
            pos = pos[density.dim]
            # Periodic boundary conditions
            # Todo: handle non orthorombic boxes here
            pos -= floor(pos/frame.box[density.dim])*frame.box[density.dim]
            push!(positions, pos)
        end
    end
    # Todo: handle non orthorombic boxes here
    V = frame.box[1] * frame.box[2] * frame.box[3]
    update!(density.values, positions; weight=1/V)
    density.used_steps += 1
    return nothing
end

function write(density::DensityProfile, trajname::String; outname="")
    if outname == ""
        outname = join(split(trajname, '.')[1:end-1], '.')
        outname = "$outname-$(density.atom).rho"
    end
    outfile = open(outname, "w")
    println(outfile, "# Density profile along dimmension ", density.dim, " for trajectory", trajname)
    println(outfile, "# x[", density.dim, "]\trho")
    for i=1:density.values.bins
        position = i*density.values.step
        println(outfile, position, "\t", density.values.weight[i])
    end
    close(outfile)
    return outname
end

function normalize!(density::DensityProfile)
    return normalize!(density.values, 1e-4*density.used_steps)
end


function clean!(density::DensityProfile)
    clean!(density.values)
    density.used_steps = 0
    return nothing
end