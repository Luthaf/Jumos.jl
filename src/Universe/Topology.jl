# Copyright (c) Guillaume Fraux 2014
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

typealias Bond (UInt64, UInt64)
typealias Angle (UInt64, UInt64, UInt64)
typealias Dihedral (UInt64, UInt64, UInt64, UInt64)

include("Atom.jl")

@doc "
The `Connectivity` type hold a cache of the bonds, angles and dihedrals inside a
topology. It is not the reliable source of information, the authority is inside
the topology. All the UInt64 are references to the indexes in `Topology.atoms`.
" ->
immutable Connectivity
    hash::UInt64
    bonds::Vector{Bond}
    angles::Vector{Angle}
    dihedrals::Vector{Dihedral}
end

Connectivity() = Connectivity(0, Bond[], Angle[], Dihedral[])

@doc "
The `update!(connectivity, atoms)` function updates the connectivity by scaning
all the liaisons of all the atoms in `atoms`, and building the bonds, angles and
dihedral angles from these liaisons.
" ->
function update!(connectivity::Connectivity, all_atoms::Vector{Atom})
    hash(all_atoms) == connectivity.hash && return

    connectivity.hash = hash(all_atoms)

    for (i, atom) in enumerate(all_atoms)
        for atom2 in atom.liaisons
            # Get bonds
            j = indexin(atom2, topology.atoms)
            push!(connectivity.bonds, (i, j))
            push!(connectivity.bonds, (j, i))
            for atom3 in atom2.liaisons
                # Get angles
                k = indexin(atom3, topology.atoms)
                k == i && continue
                push!(connectivity.angles, (i, j, k))
                push!(connectivity.angles, (k, j, i))
                for atom4 in atom3.liaisons
                    # Get dihedral angles
                    m = indexin(atom4, topology.atoms)
                    m == j && continue
                    push!(connectivity.angles, (i, j, k, m))
                    push!(connectivity.angles, (m, k, j, i))
                end
            end
        end
    end
    return connectivity
end

immutable Topology
    atoms::Vector{Atom}
    connectivity::Connectivity
end

function Topology(natoms::Integer)
    atoms = Array(Atom, natoms)
    fill!(atoms, Atom())
    return Topology(atoms, Connectivity())
end
Topology() = Topology(0)

Base.size(topology::Topology) = size(topology.atoms, 1)
Base.start(t::Topology) = 1
Base.done(t::Topology, state) = (state > size(t))
Base.next(t::Topology, state) = (t[state], state + 1)

@doc "
This function updates the connectivity cache of a topology.
" ->
function update_cache!(topology::Topology)
    update!(topology.connectivity, topology.atoms)
end

function Base.show(io::IO, topology::Topology)
    update_cache!(topology)
    natoms = size(topology)
    nmolecules = size(topology.connectivity.molecules, 1)

    nbonds = size(topology.connectivity.bonds, 1)
    nangles = size(topology.connectivity.angles, 1)
    ndihedrals = size(topology.connectivity.dihedrals, 1)
    show(io, "Topology with $n_atoms atoms, $n_molecules molecules, " *
             "$n_bonds bonds, $n_angles angles, and $n_dihedrals dihedrals.")
end

Base.getindex(topology::Topology, i) = return topology.atoms[i]
Base.setindex!(topology::Topology, atom::Atom, i) = setindex!(topology.atoms, atom, i)

@doc "
Adds an atom in the topology.
" ->
function add_atom!(topology::Topology, atom::Atom)
    push!(topology.atoms, atom)
end

@doc "
`add_liaison!(topology, atom_i, atom_j)`

Adds a liaison between the atom `atom_i` and the atom `atom_j`. Both atoms can
be of type `Atom` or integers.
" ->
function add_liaison!(topology::Topology, atom_i::Atom, atom_j::Atom)
    found = 0
    for atom in topology
        if atom == atom_i
            add_liaison!(atom, atom_j)
            found += 1
        elseif atom == atom_j
            add_liaison!(atom, atom_i)
            found += 1
        end
        found == 2 && break
    end
    found == 2 || throw(
        "Can not add a liaison between atoms from outside of the universe."
    )
    return nothing
end

add_liaison!(t::Topology, ai::Integer, aj::Integer) = add_liaison!(t, t[ai], t[aj])

@doc "
Remove an atom by index in the topology.
" ->
function remove_atom!(topology::Topology, i::Real)
    deleteat!(topology.atoms, i)
end

@doc "
Remove a liaison between two atoms. The atoms can be specified either by index or
as instances of `Atom` type.
" ->
function remove_liaison!(topology::Topology, atom_i::Atom, atom_j::Atom)
    found = 0
    for atom in topology
        if atom == atom_i
            remove_liaison!(atom, atom_j)
            found += 1
        elseif atom == atom_j
            remove_liaison!(atom, atom_i)
            found += 1
        end
        found == 2 && break
    end
    found == 2 || throw(
        "Can not remove a liaison between atoms from outside of the universe."
    )
    return nothing
end

remove_liaison!(t::Topology, ai::Integer, aj::Integer) = remove_liaison!(t, t[ai], t[aj])

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
    fill!(topology.atoms, Atom("", DummyAtom))
    return topology
end
