#===============================================================================
                 Useful types for topology storage.
===============================================================================#

import Base: size, show

export Topology, Bond, Angle, Dihedral
export atomic_masses

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

size(topology::Topology) = size(topology.atoms, 1)

function show(io::IO, top::Topology)
    n_molecules = size(top.molecules)
    n_residues = size(top.residues)
    n_bonds = size(top.bonds, 1)
    n_angles = size(top.angles, 1)
    n_dihedrals = size(top.dihedrals, 1)
    show(io, string("Topology with $n_molecules molecules, $n_residues residues, ",
                "$n_bonds bonds, $n_angles angles, $n_dihedrals dihedrals."))
end

function atomic_masses(topology::Topology)
    masses = zeros(Float64, size(topology))
    @inbounds for i=1:size(topology)
        atom = topology.atoms[i]
        if atom.mass == 0.0
            atom.mass = get_mass(atom)
        end
        masses[i] = atom.mass
    end
    return masses
end
