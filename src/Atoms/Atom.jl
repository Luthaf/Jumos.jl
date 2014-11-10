#===============================================================================
                        Atom type in topologies
===============================================================================#
import Base.show

export Atom

type Atom
    name::String                # atom name
    symbol::String              # atom chemical type
    mass::Float64               # atomic mass
    special::Dict{String, Any}  # special values (charge, ...)
end

Atom(s::String) = Atom(s, s, 0, Dict())
Atom() = Atom("")

function show(io::IO, atom::Atom)
    show(io, "Atom $(atom.name) ($(atom.symbol))")
end
