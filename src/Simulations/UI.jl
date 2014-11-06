#===============================================================================
                User interface to manipulate Simulation(s)
===============================================================================#

typealias AtomType Union(Integer, String)

export add_interaction

function add_interaction(sim::MDSimulation, potential::Potential, atoms::(AtomType, AtomType))
    atom_i, atom_j = get_atom_id(sim, atoms...)
    sim.interactions[(atom_i, atom_j)] = potential
    if atom_i != atom_j
        sim.interactions[(atom_j, atom_i)] = potential
    end
    if potential ∉ sim.potentials
        push!(sim.potentials, potential)
    end
    return nothing
end

# Todo: Way to add a catchall interaction

function get_atom_id(sim::MDSimulation, atom_i::AtomType, atom_j::AtomType)
    i = isa(atom_i, Integer) ? atom_i : get_id_from_name(sim.topology, atom_i)
    j = isa(atom_j, Integer) ? atom_j : get_id_from_name(sim.topology, atom_j)
    return (i, j)
end

# Todo: get_id_from_name lookup in topology


function Simulation(sim_type::String, args...)
    if lowercase(sim_type) == "md"
        return MDSimulation(args...)
    else
        throw(SimulationConfigurationError(
            "Unknown simulation type: $type"
        ))
    end
end

# This define the default values for a simulation !
function MDSimulation(integrator=VelocityVerlet(1.0))
    interactions = Interaction[]
    forces = NaiveForces()

    enforces = BaseEnforce[]
    checks = BaseCheck[]
    computes = BaseCompute[]
    outputs = BaseOutput[]

    return MDSimulation(interactions,
                        forces,
                        integrator,
                        enforces,
                        checks,
                        computes,
                        outputs,
                        Frame()
                        )
end

# Convenient method.
MDSimulation(timestep::Real) = MDSimulation(VelocityVerlet(timestep))
