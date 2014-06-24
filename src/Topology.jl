#===============================================================================
                 Useful types for topology storage.
===============================================================================#

import Base.show

type Atom
    name::String                # atom name
    symbol::String              # atom chemical type
    special::Dict{String, Any}  # special values (mass, charge, ...)
end

Atom(s::String) = Atom(s, s, Dict())
Atom() = Atom("")

function Base.show(io::IO, atom::Atom)
    print("Atom $(atom.name) ($(atom.symbol))")
end

typealias Bond (Int, Int)
typealias Angle (Int, Int, Int)
typealias Dihedral (Int, Int, Int, Int)

type Topology
    atoms::Array{Atom,1}
    molecules::Dict{String, Array{Int,1}}
    residues::Dict{String, Array{Int,1}}
    bonds::Array{Bond, 1}
    angles::Array{Angle, 1}
    dihedrals::Array{Dihedral, 1}  # Reals dihedrals
    impropers::Array{Dihedral, 1}  # Impropers dihedrals
end

Topology(natoms::Integer) = Topology(Array(Atom, natoms),
                                     Dict(),
                                     Dict(),
                                     Array(Bond, 0),
                                     Array(Angle, 0),
                                     Array(Dihedral, 0),
                                     Array(Dihedral, 0)
                                    )
Topology() = Topology(0)

function Base.size(a::Dict{String, Array{Int64,1}})
    # Just count the number of dict entry
    i = 0
    for _ in a
        i += 1
    end
    return i
end

function Base.show(io::IO, top::Topology)
    n_molecules = size(top.molecules)
    n_residues = size(top.residues)
    n_bonds = size(top.bonds, 1)
    n_angles = size(top.angles, 1)
    n_dihedrals = size(top.dihedrals, 1)
    print(string("Topology with $n_molecules molecules, $n_residues residues, ",
                "$n_bonds bonds, $n_angles angles, $n_dihedrals dihedrals."))
end

include("Topologies/LAMMPS.jl")
