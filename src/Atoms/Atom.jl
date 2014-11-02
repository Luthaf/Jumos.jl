#===============================================================================
                        Atom type in topologies
===============================================================================#
import Base.show

export Atom

type Atom
    name::String                # atom name
    symbol::String              # atom chemical type
    special::Dict{String, Any}  # special values (mass, charge, ...)
end

Atom(s::String) = Atom(s, s, Dict())
Atom() = Atom("")

function show(io::IO, atom::Atom)
    show(io, "Atom $(atom.name) ($(atom.symbol))")
end
