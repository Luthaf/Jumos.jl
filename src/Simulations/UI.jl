# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#               User interface to manipulate Simulation(s)
# ============================================================================ #

typealias AtomType Union(Integer, String)

export add_interaction, set_cell, read_topology, read_positions, add_output ,
       set_frame

# Todo: Way to add a catchall interaction
function add_interaction(sim::MDSimulation, potential::BasePotential, atoms::(AtomType, AtomType); cutoff=12.0)
    pot = Potential(potential, cutoff=cutoff)
    atom_i, atom_j = get_atom_id(sim, atoms...)

    sim.interactions[(atom_i, atom_j)] = pot
    if atom_i != atom_j
        sim.interactions[(atom_j, atom_i)] = pot
    end
end

add_interaction(sim::MDSimulation, pot::BasePotential, at_i::AtomType) = add_interaction(sim, pot, (at_i, at_i))

# TODO: add interaction while specifing the cutoff.

function get_atom_id(sim::MDSimulation, atom_i::AtomType, atom_j::AtomType)
    i = isa(atom_i, Integer) ? atom_i : get_id_from_name(sim.topology, atom_i)
    j = isa(atom_j, Integer) ? atom_j : get_id_from_name(sim.topology, atom_j)
    return (i, j)
end

function Simulation(sim_type::String, args...)
    if lowercase(sim_type) == "md"
        return MDSimulation(args...)
    else
        throw(SimulationConfigurationError(
            "Unknown simulation type: $sim_type"
        ))
    end
end

function set_cell(sim::MDSimulation, cell::UnitCell)
    sim.cell = cell
end

function set_cell(sim::MDSimulation, size)
    return set_cell(sim, UnitCell(size...))
end

function set_cell{T<:Type{Universe.AbstractCellType}}(sim::MDSimulation, cell_type::T, size = (0.0,))
    return set_cell(sim, UnitCell(cell_type(), size...))
end

function read_topology(sim::MDSimulation, filename::AbstractString)
    sim.topology = Topology(filename)
end

function read_positions(sim::MDSimulation, filename::AbstractString)
    reader = opentraj(filename, cell=sim.cell, topology=sim.topology)
    read_frame!(reader, 1, sim.frame)

    sim.frame.cell = sim.cell
    sim.frame.topology = sim.topology
end

# Todo:
# function read_velocities(sim::MDSimulation, filename::AbstractString)

function add_output(sim::MDSimulation, out::BaseOutput)
    push!(sim.outputs, out)
end

@doc "
`set_frame(sim::MDSimulation, frame::Frame)`

Set the simulation frame to `frame`, and update internal values
" ->
function set_frame(sim::MDSimulation, frame::Frame)
    sim.frame = frame
    sim.cell = frame.cell
    sim.data[:frame] = sim.frame
    sim.topology = sim.frame.topology
    natoms = size(sim.frame)
    sim.frame.velocities = Array3D(Float64, natoms)
    return nothing
end
