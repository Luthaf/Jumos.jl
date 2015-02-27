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
export setframe!

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

@doc "
`setframe!(universe, frame)`: set the `universe` frame to `frame`.
" ->
function setframe!(univ::Universe, frame::Frame)
    univ.frame = frame
    return nothing
end

@doc "
`setcell!(universe, cell)`

Set the universe unit cell. `cell` can be an UnitCell instance or a list of cell
lenghts and angles.

`setcell!(universe, celltype, params)`

Set the universe unit cell to a cell with type `celltype` and cell parameters from
`params`
" ->
function setcell!(univ::Universe, cell::UnitCell)
    sim.cell = cell
end

function setcell!(univ::Universe, params)
    return setcell!(sim, UnitCell(params...))
end

function setcell!{T<:Type{AbstractCellType}}(univ::Universe, celltype::T, params = (0.0,))
    return setcell!(sim, UnitCell(celltype(), params...))
end

# Todo: Way to add a catchall interaction
function add_interaction(sim::Simulation, potential::PotentialFunction, atoms...;
                         computation=:auto, kwargs...)
    atoms_id = get_atoms_id(sim, atoms...)

    interactions = get_interactions(potential, atoms_id...; computation=computation, kwargs...)

    for (index, potential_computation) in interactions
        sim.interactions[index] = potential_computation
    end
    return nothing
end

include("Distances.jl")
