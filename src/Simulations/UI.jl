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

export add_interaction, set_cell, read_topology, read_positions, set_frame,
       add_compute, add_enforce, add_check, add_output

# Todo: Way to add a catchall interaction
function add_interaction(sim::MolecularDynamic, potential::BasePotential, atoms::(AtomType, AtomType); cutoff=12.0)
    pot = Potential(potential, cutoff=cutoff)
    atom_i, atom_j = get_atom_id(sim, atoms...)

    sim.interactions[(atom_i, atom_j)] = pot
    if atom_i != atom_j
        sim.interactions[(atom_j, atom_i)] = pot
    end
end

add_interaction(sim::MolecularDynamic, pot::BasePotential, at_i::AtomType) = add_interaction(sim, pot, (at_i, at_i))

# TODO: add interaction while specifing the cutoff.

function get_atom_id(sim::MolecularDynamic, atom_i::AtomType, atom_j::AtomType)
    i = isa(atom_i, Integer) ? atom_i : get_id_from_name(sim.topology, atom_i)
    j = isa(atom_j, Integer) ? atom_j : get_id_from_name(sim.topology, atom_j)
    return (i, j)
end

function set_cell(sim::MolecularDynamic, cell::UnitCell)
    sim.cell = cell
end

function set_cell(sim::MolecularDynamic, size)
    return set_cell(sim, UnitCell(size...))
end

function set_cell{T<:Type{Universe.AbstractCellType}}(sim::MolecularDynamic, cell_type::T, size = (0.0,))
    return set_cell(sim, UnitCell(cell_type(), size...))
end

function read_topology(sim::MolecularDynamic, filename::AbstractString)
    sim.topology = Topology(filename)
end

function read_positions(sim::MolecularDynamic, filename::AbstractString)
    reader = opentraj(filename, cell=sim.cell, topology=sim.topology)
    read_frame!(reader, 1, sim.frame)

    sim.frame.cell = sim.cell
    sim.frame.topology = sim.topology
end

# Todo:
# function read_velocities(sim::MolecularDynamic, filename::AbstractString)

function add_output(sim::MolecularDynamic, output::BaseOutput)
    if !ispresent(sim, output)
        push!(sim.outputs, output)
    else
        warn("$output is aleady present in this simulation")
    end
    return sim.outputs
end

function add_compute(sim::MolecularDynamic, compute::BaseCompute)
    if !ispresent(sim, compute)
        push!(sim.computes, compute)
    else
        warn("$compute is aleady present in this simulation")
    end
    return sim.computes
end

function add_enforce(sim::MolecularDynamic, enforce::BaseEnforce)
    if !ispresent(sim, enforce)
        push!(sim.enforces, enforce)
    else
        warn("$enforce is aleady present in this simulation")
    end
    return sim.enforces
end

function add_check(sim::MolecularDynamic, check::BaseCheck)
    if !ispresent(sim, check)
        push!(sim.checks, check)
    else
        warn("$check is aleady present in this simulation")
    end
    return sim.checks
end

function ispresent(sim::MolecularDynamic, algo)
    algo_type = typeof(algo)
    for field in [:checks, :computes, :outputs, :enforces]
        for elem in getfield(sim, field)
            if isa(elem, algo_type)
                return true
            end
        end
    end
    return false
end

@doc "
`set_frame(sim::MolecularDynamic, frame::Frame)`

Set the simulation frame to `frame`, and update internal values
" ->
function set_frame(sim::MolecularDynamic, frame::Frame)
    sim.frame = frame
    sim.cell = frame.cell
    sim.data[:frame] = sim.frame
    sim.topology = sim.frame.topology
    natoms = size(sim.frame)
    sim.frame.velocities = Array3D(Float64, natoms)
    return nothing
end

function set_integrator(sim::MolecularDynamic, integrator::BaseIntegrator)
    sim.integrator = integrator
end

function set_forces_computation(sim::MolecularDynamic, forces_computer::BaseForcesComputer)
    sim.forces_computer = forces_computer
end
