# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#             Universe type, holding all the simulated system data
# ============================================================================ #
export Universe
export setframe!, setcell!, add_interaction!, get_masses!, check_masses

include("Topology.jl")
include("UnitCell.jl")
include("Frame.jl")
include("Interactions.jl")

type Universe
    cell::UnitCell
    topology::Topology
    interactions::Interactions
    frame::Frame
    masses::Vector{Float64}
    data::Dict{Symbol, Any}
end

function Universe(cell::UnitCell, topology::Topology)
    univ = Universe(cell,
                    topology,
                    Interactions(),
                    Frame(size(topology)),
                    Float64[],
                    Dict{Symbol, Any}()
            )
    univ.data[:universe] = univ
    return univ
end

function Base.size(u::Universe)
    assert(size(u.frame) == size(u.topology))
    return size(u.frame)
end

@doc "
`get_masses!(universe)`: get masses from the topology, and store them in the
universe internal data. Returns the masses array.
" ->
function get_masses!(u::Universe)
    u.masses = atomic_masses(u.topology)
    return u.masses
end

@doc "
`check_masses(universe)`: Check that all masses are defined and are not equals to 0.
" ->
function check_masses(univ::Universe)
    if countnz(univ.masses) != size(univ.topology)
        bad_masses = Set()
        for (i, val) in enumerate(univ.masses)
            if val == 0.0
                union!(bad_masses, [univ.topology[i].name])
            end
        end
        missing = join(bad_masses, " ")
        throw(JumosError(
                "Missing masses for the following atomic types: $missing."
            ))
    end
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

function setcell!{T<:Type{AbstractCellType}}(univ::Universe, celltype::T, params = tuple())
    return setcell!(sim, UnitCell(celltype, params...))
end

# Todo: Way to add a catchall interaction
function add_interaction!(univ::Universe, pot::PotentialFunction, atoms...;
                         computation=:auto, kwargs...)
    atoms_id = get_atoms_id(univ.topology, atoms...)
    computation = get_computation(pot; computation=computation, kwargs...)
    push!(univ.interactions, computation, atoms_id...)
    return nothing
end

include("Distances.jl")
