# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#               Interactions: putting together potentials and atoms
# ============================================================================ #

include("potentials.jl")
export Interactions
export pairs, bonds, angles, dihedrals

"
Interactions are stored in `Interactions` object in such way that the
`Interactions.pairs` matrix contains all the non-bonded interaction for
a pair `(i, j)` at index `(min(i, j), max(i, j))`. The bonded interactions
follows the same order, but in the `Interactions.bonds` field.

The angle interactions corresponding to (i, j, k) atoms are stored in
`Interactions.angles` at index `(min(i, k), j, max(i, k))`.

The dihedral interactions corresponding to (i, j, k, m) atoms are stored in
`Interactions.dihedral` at index `(min(i, m), min(j, k), max(j, k), max(i, m))`.
"
immutable Interactions
    pairs::Matrix{Vector{PotentialComputation}}
    bonds::Matrix{Vector{PotentialComputation}}
    angles::Dict{(Int, Int, Int), Vector{PotentialComputation}}
    dihedrals::Dict{(Int, Int, Int, Int), Vector{PotentialComputation}}
end

function Interactions(ntypes::Integer = 4)
    pairs = Array(Vector{PotentialComputation}, ntypes, ntypes)
    fill!(pairs, PotentialComputation[])
    bonds = Array(Vector{PotentialComputation}, ntypes, ntypes)
    fill!(bonds, PotentialComputation[])
    angles = Dict{(Int, Int, Int), Vector{PotentialComputation}}()
    dihedrals = Dict{(Int, Int, Int, Int), Vector{PotentialComputation}}()
    return Interactions(pairs, bonds, angles, dihedrals)
end

function Base.push!{T<:ShortRangePotential}(int::Interactions, com::PotentialComputation{T}, i::Int, j::Int)
    i, j = minmax(i, j)
    push!(int.pairs[i, j], com)
end

function Base.push!{T<:BondedPotential}(int::Interactions, com::PotentialComputation{T}, i::Int, j::Int)
    i, j = minmax(i, j)
    push!(int.bonds[i, j], com)
end

function Base.push!{T<:AnglePotential}(int::Interactions, com::PotentialComputation{T}, i::Int, j::Int, k::Int)
    i, k = minmax(i, k)
    if haskey(int.angles, (i, j, k))
        push!(int.angles[(i, j, k)], com)
    else
        int.angles[(i, j, k)] = PotentialComputation[com,]
    end
end

function Base.push!{T<:DihedralPotential}(int::Interactions, com::PotentialComputation{T}, i::Int, j::Int, k::Int, m::Int)
    if max(i, j) <= max(k, m)
        if haskey(int.dihedrals, (i, j, k, m))
            push!(int.dihedrals[(i, j, k, m)], com)
        else
            int.dihedrals[(i, j, k, m)] = PotentialComputation[com,]
        end
    else
        if haskey(int.dihedrals, (m, k, j, i))
            push!(int.dihedrals[(m, k, j, i)], com)
        else
            int.dihedrals[(m, k, j, i)] = PotentialComputation[com,]
        end
    end
end

@doc "
`pairs(interactions, i, j)`

Get a vector of applicable non-bonded interactions between the atoms with indexes
`i` and `j`.
" ->
function pairs(int::Interactions, i::Int, j::Int)
    i, j = minmax(i, j)
    return int.pairs[i, j]
end

@doc "
`bonds(interactions, i, j)`

Get a vector of applicable bonded interactions between the atoms with indexes
`i` and `j`.
" ->
function bonds(int::Interactions, i::Int, j::Int)
    i, j = minmax(i, j)
    return int.bonds[i, j]
end

@doc "
`angles(interactions, i, j, k)`

Get a vector of applicable angle interactions between the atoms with indexes
`i`, `j` and `k`.
" ->
function angles(int::Interactions, i::Int, j::Int, k::Int)
    i, k = minmax(i, k)
    return int.angles[(i, j, k)]
end

@doc "
`dihedrals(interactions, i, j, k, m)`

Get a vector of applicable dihedral interactions between the atoms with indexes
`i`, `j`, `k` and `m`.
" ->
function dihedrals(int::Interactions, i::Int, j::Int, k::Int, m::Int)
    if max(i, j) <= max(k, m)
        return int.dihedrals[(i, j, k, l)]
    else
        return int.dihedrals[(l, k, j, i)]
    end
end

# Associations between symbols and computations for the get_computation function.
COMPUTATIONS = Dict(
    :cutoff=>CutoffComputation,
    :direct=>DirectComputation,
    :table=>TableComputation,
)

function get_computation(potential::ShortRangePotential; kwargs...)
    kwargs = Dict{Symbol, Any}(kwargs)
    if kwargs[:computation] == :auto
        if !haskey(kwargs, :cutoff)
            computation = CutoffComputation(potential)
        else
            computation = CutoffComputation(potential, cutoff=kwargs[:cutoff])
        end
    else
        computation = COMPUTATIONS[kwargs[:computation]](potential; kwargs...)
    end
    return computation
end

function get_computation(potential::BondedPotential; kwargs...)
    kwargs = Dict{Symbol, Any}(kwargs)
    if kwargs[:computation] == :auto
        computation = DirectComputation(potential)
    else
        computation = COMPUTATIONS[kwargs[:computation]](potential; kwargs...)
    end
    return computation
end
