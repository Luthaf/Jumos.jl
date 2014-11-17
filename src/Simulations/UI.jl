#===============================================================================
                User interface to manipulate Simulation(s)
===============================================================================#

typealias AtomType Union(Integer, String)

export add_interaction, set_box, read_topology, read_positions, add_output

# Todo: Way to add a catchall interaction
function add_interaction(sim::MDSimulation, potential::BasePotential, atoms::(AtomType, AtomType))
    pot = Potential(potential)
    atom_i, atom_j = get_atom_id(sim, atoms...)

    sim.interactions[(atom_i, atom_j)] = pot
    if atom_i != atom_j
        sim.interactions[(atom_j, atom_i)] = pot
    end
end

add_interaction(sim::MDSimulation, pot::BasePotential, at_i::AtomType) = add_interaction(sim, pot, (at_i, at_i))

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

function set_box(sim::MDSimulation, box::SimBox)
    sim.box = box
end

function set_box(sim::MDSimulation, size)
    return set_box(sim, SimBox(size...))
end

function set_box{T<:Type{Universe.AbstractBoxType}}(sim::MDSimulation, box_type::T, size = (0.0,))
    return set_box(sim, SimBox(box_type(), size...))
end

function read_topology(sim::MDSimulation, filename::AbstractString)
    sim.topology = Topology(filename)
end

function read_positions(sim::MDSimulation, filename::AbstractString)
    reader = opentraj(filename, box=sim.box, topology=sim.topology)
    read_frame!(reader, 1, sim.data)

    sim.data.box = sim.box
    sim.data.topology = sim.topology
end

# Todo:
# function read_velocities(sim::MDSimulation, filename::AbstractString)

function add_output(sim::MDSimulation, out::BaseOutput)
    push!(sim.outputs, out)
end
