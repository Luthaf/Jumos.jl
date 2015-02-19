# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#             Universe type, holding all the simulated system data
# ============================================================================ #
export Universe, Interaction

include("Topology.jl")
include("UnitCell.jl")
include("Frame.jl")

abstract Interaction

type Universe
    cell::UnitCell
    topology::Topology
    interactions::Vector{Interaction}
    frame::Frame
    masses::Vector{Float64}
    data::Dict{Symbol, Any}
end

Universe(cell::UnitCell, topology::Topology) = Universe(
    cell,
    topology,
    Interaction[],
    Frame(size(topology)),
    Float64[],
    Dict{Symbol, Any}()
)

Universe(natoms::Integer) = Universe(
    UnitCell(),
    Topology(),
    Interaction[],
    Frame(natoms),
    Float64[],
    Dict{Symbol, Any}()
)

function get_masses!(u::Universe)
    u.masses = atomic_masses(u.topology)
    return u.masses
end

function add_atom!(u::Universe, atom::Atom)
    add_atom!(u.topology, atom)
end

function add_liaison!(u::Universe, atom_i::Atom, atom_j::Atom)
    add_liaison!(u.topology, atom_i, atom_j)
end

function remove_atom!(u::Universe, index)
    remove_atom!(u.topology, index)
end

function remove_liaison!(u::Universe, atom_i::Atom, atom_j::Atom)
    remove_liaison!(u.topology, atom_i, atom_j)
end

include("Distances.jl")
