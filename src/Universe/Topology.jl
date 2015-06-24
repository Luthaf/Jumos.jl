# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                  Useful types for topology storage.
# ============================================================================ #

export Topology, Bond, Angle, Dihedral
export atomic_masses, get_id_from_name, dummy_topology
export add_atom!, add_liaison!, remove_atom! , remove_liaison!

typealias Bond Tuple{UInt64, UInt64}
typealias Angle Tuple{UInt64, UInt64, UInt64}
typealias Dihedral Tuple{UInt64, UInt64, UInt64, UInt64}

include("Atom.jl")

@doc "
The `Connectivity` type hold a cache of the bonds, angles and dihedrals inside a
topology. It is not the reliable source of information, the authority is inside
the topology. All the UInt64 are references to the indexes in `Topology.atoms`.
" ->
type Connectivity
    hash::UInt64
    bonds::Vector{Bond}
    angles::Vector{Angle}
    dihedrals::Vector{Dihedral}
end

Connectivity() = Connectivity(0, Bond[], Angle[], Dihedral[])

share_one_element(a, b) = length(intersect(a, b)) == 1

@doc "
The `update!(connectivity, atoms)` function updates the connectivity by scaning
all the liaisons of all the atoms in `atoms`, and building the bonds, angles and
dihedral angles from these liaisons.
" ->
function update!(connectivity::Connectivity, liaisons::Vector{Bond})
    hash(liaisons) == connectivity.hash && return
    connectivity.hash = hash(liaisons)

    empty!(connectivity.bonds)
    empty!(connectivity.angles)
    empty!(connectivity.dihedrals)

    for (i, j) in liaisons
        # Get bonds
        push!(connectivity.bonds, (min(i, j), max(i, j)))
        for (k, m) in liaisons
            # Get angles
            share_one_element((k, m), (i, j)) || continue
            at2 = intersect((k, m), (i, j))[1]
            at1 = setdiff((i, j), (at2,))[1]
            at3 = setdiff((k, m), (at2,))[1]
            # Maintains order in the angle storage
            at1, at3 = minmax(at1, at3)
            push!(connectivity.angles, (at1, at2, at3))
            for (n, o) in liaisons
                # Get dihedral angles
                share_one_element((at1, at2, at3), (n, o)) || continue
                tmp3 = intersect((at1, at2, at3), (n, o))[1]
                at1, at2 = setdiff((at1, at2, at3), (tmp3,))[1:2]
                at3 = tmp3
                at4 = setdiff((n, o), (at3,))[1]
                # Maintains order in the dihedral storage
                at1, at4 = minmax(at1, at4)
                at2, at3 = minmax(at2, at3)
                push!(connectivity.dihedral, (at1, at2, at3, at4))
            end
        end
    end
    return connectivity
end

immutable Topology
    templates::Vector{Atom}
    atoms::Vector{Int}
    liaisons::Vector{Bond}
    connectivity::Connectivity
end

function Topology(natoms::Integer)
    atoms = Array(Int, natoms)
    return Topology(Atom[], atoms, Bond[], Connectivity())
end
Topology() = Topology(0)

Base.size(topology::Topology) = size(topology.atoms, 1)
Base.start(t::Topology) = 1
Base.done(t::Topology, state) = (state > size(t))
Base.next(t::Topology, state) = (t[state], state + 1)

@doc "
`update_cache!(topology)`

This function updates the connectivity cache of a topology.
" ->
function update_cache!(topology::Topology)
    update!(topology.connectivity, topology.liaisons)
end

function Base.show(io::IO, topology::Topology)
    update_cache!(topology)
    natoms = size(topology)

    nbonds = size(topology.connectivity.bonds, 1)
    nangles = size(topology.connectivity.angles, 1)
    ndihedrals = size(topology.connectivity.dihedrals, 1)
    show(io, "Topology with $natoms atoms, $nbonds bonds, $nangles angles," *
             " and $ndihedrals dihedrals.")
end

Base.getindex(topology::Topology, i) = topology.templates[topology.atoms[i]]

"
 `firstin(a, i)`

Get the first element equals to `i` in `a`"
@inline function firstin(a, i)
    for (idx, val) in enumerate(a)
        if i == val
            return idx
        end
    end
    return -1
end

function Base.setindex!(topology::Topology, atom::Atom, i)
    0 < i <= size(topology) || throw(BoundsError(
            "$(size(topology))-atoms topology at index $i"))

    if atom in topology.templates
        topology.atoms[i] = firstin(topology.templates, atom)
    else
        # Create a new atomic template
        push!(topology.templates, atom)
        topology.atoms[i] = size(topology.templates, 1)
    end
end

@doc "
Adds an atom in the topology.
" ->
function add_atom!(topology::Topology, atom::Atom)
    atom_idx = findin(topology.templates, [atom])
    if length(atom_idx) == 1
        push!(topology.atoms, atom_idx[1])
    else
        # Create a new atomic template
        push!(topology.templates, atom)
        push!(topology.atoms, size(topology.templates, 1))
    end
end

@doc "
`add_liaison!(topology, i, j)`

Adds a liaison between the atoms at indexes `i` and `j`.
" ->
function add_liaison!(topology::Topology, i::Integer, j::Integer)
    assert(i <= size(topology))
    assert(j <= size(topology))
    push!(topology.liaisons, (min(i, j), max(i, j)))
    return nothing
end

@doc "
`remove_atom!(topology, i)`

Remove an atom by index in the topology.
" ->
function remove_atom!(topology::Topology, idx::Real)
    deleteat!(topology.atoms, idx)
    liaisons = []
    for (k, (i, j)) in topology.liaisons
        if idx in (i, j)
            deleteat!(topology.liaisons, k)
        end
    end
    return nothing
end

@doc "
`remove_liaison!(topology, i, j)`

Remove a liaison between two atoms, specified either by index.
" ->
function remove_liaison!(topology::Topology, i::Integer, j::Integer)
    idx = findin(topology.liaisons, Bond[(min(i, j), max(i, j))])
    if length(idx) == 1
        deleteat!(topology.liaisons, idx[1])
    end
    return nothing
end

@doc "
`atomic_masses(topology)`

Get the masses of all the atoms in the system.
" ->
function atomic_masses(topology::Topology)
    masses = zeros(Float64, size(topology))
    @inbounds for i=1:size(topology)
        masses[i] = mass(topology[i])
    end
    return masses
end

@doc "
`dummy_topology(natoms)`

Get a dummy topology of size `natoms`.
" ->
function dummy_topology(natoms::Integer)
    topology = Topology(natoms)
    for i=1:natoms
        topology[i] = Atom("", DummyAtom)
    end
    return topology
end

function get_atoms_id(topology::Topology, atoms...)
    idx = Int[]
    for atom in atoms
        atom_idx = isa(atom, Integer) ? atom : get_id_from_name(topology, atom)
        push!(idx, atom_idx)
    end
    return idx
end

"
Try to guess the atomic id from the name. If multiple names are the same, the first
one is picked.
"
function get_id_from_name(topology::Topology, atom_name)
    name = Symbol(atom_name)
    for (i, atom) in enumerate(topology.templates)
        if name == atom.label
            return i
        end
    end
    throw(JumosError("I can not find the name $atom_name in this topology."))
end
