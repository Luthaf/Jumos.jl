#===============================================================================
                 Useful types for topology storage.
===============================================================================#
import Base: size, show

export Topology, Atom, Bond, Angle, Dihedral
export read_topology

type Atom
    name::String                # atom name
    symbol::String              # atom chemical type
    special::Dict{String, Any}  # special values (mass, charge, ...)
end

Atom(s::String) = Atom(s, s, Dict())
Atom() = Atom("")

function show(io::IO, atom::Atom)
    print("Atom $(atom.name) ($(atom.symbol))")
end

typealias Bond (Int, Int)
typealias Angle (Int, Int, Int)
typealias Dihedral (Int, Int, Int, Int)


type Topology
    atoms::Vector{Atom}
    molecules::Dict{String, Array{Int,1}}
    residues::Dict{String, Array{Int,1}}
    bonds::Vector{Bond}
    angles::Vector{Angle}
    dihedrals::Vector{Dihedral}  # Reals dihedrals
    impropers::Vector{Dihedral}  # Impropers dihedrals
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

function size(a::Dict{String, Array{Int64,1}})
    # Just count the number of dict entry
    i = 0
    for (k, v) in a
        i += 1
    end
    return i
end

function show(io::IO, top::Topology)
    n_molecules = size(top.molecules)
    n_residues = size(top.residues)
    n_bonds = size(top.bonds, 1)
    n_angles = size(top.angles, 1)
    n_dihedrals = size(top.dihedrals, 1)
    show(io, string("Topology with $n_molecules molecules, $n_residues residues, ",
                "$n_bonds bonds, $n_angles angles, $n_dihedrals dihedrals."))
end

include("Topologies/XYZ.jl")
include("Topologies/LAMMPS.jl")

function read_topology(filename)
    extension = split(strip(filename), ".")[end]
    if extension == "xyz"
        info("Reading topology in XYZ format")
        return read_xyz_topology(filename)
    elseif extension == "lmp"
        info("Reading topology in LAMMPS format")
        return read_lmp_topology(filename)
    else
        error("The '$extension' extension is not recognized")
    end
end

Topology(filename::String) = read_topology(filename)
