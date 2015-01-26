# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#               User interface to manipulate Simulations
# ============================================================================ #

export add_interaction, set_cell, read_topology, read_positions, set_frame,
       add_compute, add_control, add_check, add_output

# Todo: Way to add a catchall interaction
function add_interaction(sim::MolecularDynamic, potential::PotentialFunction, atoms...;
                         computation=:auto, kwargs...)
    atoms_id = get_atoms_id(sim, atoms...)

    interactions = get_interactions(potential, atoms_id...; computation=computation, kwargs...)

    for (index, potential_computation) in interactions
        sim.interactions[index] = potential_computation
    end
    return nothing
end

function get_atoms_id(sim::MolecularDynamic, atoms...)
    idx = Int[]
    for atom in atoms
        atom_idx = isa(atom, Integer) ? atom : get_id_from_name(sim.topology, atom)
        push!(idx, atom_idx)
    end
    return idx
end

@doc "
Get the interaction — *i.e.* the pair (atoms_index...)=>PotentialComputation —
for a potential function.
" ->
function get_interactions(potential, atoms...; kwargs...)
    # TODO: implement this for every kind of potential function
    throw(NotImplementedError(
        "Can not build an interaction for a $(typeof(potential)) potential."
    ))
end

function get_interactions(potential::Potential2Body, atoms...; kwargs...)
    interactions = cell(2)
    if length(atoms) == 1
        atoms = [atoms[1], atoms[1]]
    elseif length(atoms) > 2
        throw(SimulationConfigurationError(
            "Can not build a pair interaction with more than two particles"
        ))
    end

    computation = get_computation(potential; kwargs...)

    # 2-body potentials are reflexif
    interactions[1] = (tuple(atoms...), computation)
    interactions[2] = (tuple(reverse(atoms)...), computation)
    return interactions
end

# Associations between symbols and computations for the get_computation function.
COMPUTATIONS = Dict(
    :cutoff=>CutoffComputation,
    :direct=>DirectComputation,
    :table=>TableComputation,
)

function get_computation(potential::ShortRangePotential; kwargs...)
    kwargs = Dict{Symbol, Any}(kwargs)
    if kwargs[:computation] == :auto
        if !haskey(kwargs, :cutoff)
            computation = CutoffComputation(potential)
        else
            computation = CutoffComputation(potential, cutoff=kwargs[:cutoff])
        end
    else
        computation = COMPUTATIONS[kwargs[:computation]](potential; kwargs...)
    end
    return computation
end

function get_computation(potential::BondedPotential; kwargs...)
    kwargs = Dict{Symbol, Any}(kwargs)
    if kwargs[:computation] == :auto
        computation = DirectComputation(potential)
    else
        computation = COMPUTATIONS[kwargs[:computation]](potential; kwargs...)
    end
    return computation
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

function add_control(sim::MolecularDynamic, control::BaseControl)
    if !ispresent(sim, control)
        push!(sim.controls, control)
    else
        warn("$control is aleady present in this simulation")
    end
    return sim.controls
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
    for field in [:checks, :computes, :outputs, :controls]
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
