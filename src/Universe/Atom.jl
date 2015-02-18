# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Atom type in topologies
# ============================================================================ #

export Atom, mass

include("PeriodicTable.jl")

abstract AtomType
immutable DummyAtom <: AtomType end
immutable Element <: AtomType end
immutable CorseGrain <: AtomType end
immutable UnknownAtom <: AtomType end

type Atom{T <: AtomType}
    label::Symbol                   # atom name
    # Atomic data
    mass::Float64                   # atom mass
    charge::Float64                 # atom charge
    properties::Dict{Symbol, Any}   # any special special property
end

function Atom(s::String, atype = AtomType)
    if atype == AtomType
        if Symbol(s) in PERIODIC_TABLE
            atype = Element
        else
            atype = CorseGrain
        end
    end
    return Atom{atype}(Symbol(s), Atom[], mass(Symbol(s)), 0, Dict{Symbol, Any}())
end
Atom() = Atom("", UnknownAtom)

function Base.show(io::IO, atom::Atom)
    show(io, "Atom $(atom.label)")
end

function mass(atom::Atom)
    return mass(atom.label)
end

function mass(name::Symbol)
    res = 0.0
    if haskey(ATOMIC_MASSES, name)
        # TODO: fix the method error in internal(ATOMIC_MASSES[name])
        res =  ATOMIC_MASSES[name].val
    end
    return res
end
