# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                 Computing radial distribution functions
# ============================================================================ #
export RDF

type RDF
    values::Histogram{Float64}
    atom_i::String
    atom_j::String
    used_steps::Int
    nparticle::BigInt
    cell::UnitCell
end

function RDF(atom_i::String, atom_j::String; bins=200)
    hist = Histogram(Float64, bins)
    return RDF(hist, atom_i, atom_j, 0, 0, UnitCell())
end

RDF(atom_i::String; kwargs...) = RDF(atom_i, atom_i; kwargs...)

function update!(rdf::RDF, frame::Frame)
    const natoms = length(frame.positions)
    distances = Array(Float64, natoms, natoms)
    distance_array(frame, distances)

    dists = Float64[]
    sizehint!(dists, 2*natoms)

    @inbounds for i=1:natoms
        if frame.topology[i].name == rdf.atom_i
            rdf.nparticle += 1
            @inbounds for j=(i+1):natoms
                if frame.topology[j].name == rdf.atom_j
                    push!(dists, distances[i, j])
                end
            end
        end
    end

    if rdf.cell == UnitCell(0.0) initialize!(rdf, frame) end

    update!(rdf.values, dists, weight=2.0)
    rdf.used_steps += 1
    return nothing
end

function initialize!(rdf::RDF, frame::Frame)
    @assert frame.cell != UnitCell(0.0) "The simulation cell can not be null for RDF computations"
    rdf.cell = frame.cell
    rdf.values.min = 0.0
    rdf.values.max = 0.5*min(rdf.cell.x, rdf.cell.y, rdf.cell.z)
end

function Base.write(rdf::RDF, trajname::String; outname="")
    if outname == ""
        outname = join(split(trajname, '.')[1:end-1], '.')
        outname = "$outname-$(rdf.atom_i)-$(rdf.atom_j).rdf"
    end
    outfile = open(outname, "w")
    println(outfile, "# Radial distribution function for atoms ", rdf.atom_i, " & ",
                rdf.atom_j, " for trajectory", trajname)
    for i=1:rdf.values.bins
        position = i*rdf.values.step
        println(outfile, position, "\t", rdf.values.weight[i])
    end
    close(outfile)
    return outname
end

function normalize!(rdf::RDF)
    # Todo: handle non orthorombic celles here
    function norm(i::Integer)
        V = rdf.cell[1]*rdf.cell[2]*rdf.cell[3]
        n_particles = rdf.nparticle/(rdf.used_steps)
        rho = n_particles/V
        dr = rdf.values.step
        f = j -> 4*pi/3 * (dr*(j + 1))^3
        return rho * n_particles * rdf.used_steps * (f(i+1) - f(i))
    end

    normalize!(rdf.values, norm)
end

function clean!(rdf::RDF)
    clean!(rdf.values)
    rdf.used_steps = 0
    return nothing
end
