#===============================================================================
                    Molecular dynamic simulations
===============================================================================#

abstract Simulation

include("SimulationData.jl")

include("MD/potentials.jl")
include("MD/forces.jl")
include("MD/integrators.jl")

include("MD/enforce.jl")
include("MD/check.jl")
include("MD/compute.jl")
include("MD/output.jl")

type MDSimulation <: Simulation
    potentials      ::Vector{BasePotential}
    forces_computer ::BaseForcesComputer
    integrator!     ::BaseIntegrator
    enforces        ::Vector{BaseEnforce}
    checks          ::Vector{BaseCheck}
    computes         ::Vector{BaseCompute}
    outputs          ::Vector{BaseOutput}
    data            ::SimulationData
end

# Run a Molecular Dynamics simulation for nsteps steps
function run!(sim::MDSimulation, nsteps::Integer)

    check_settings(sim)

    for i=1:nnsteps
        get_forces(sim)
        integrate(sim)
        enforce(sim)
        check(sim)
        compute(sim)
        output(sim)
    end
    return nothing
end

# Check that everything is effectivelly defined by the user
function check_settings(sim::MDSimulation)
    # throw(SimulationConfigurationError)
end

# Compute forces between atoms at a given step
function get_forces(sim::MDSimulation)
    sim.data.forces = sim.forces_computer(sim.data.positions)
end

# Integrate the equations of motion
function integrate(sim::MDSimulation)
    sim.integrator!(sim.data)
end

# Enforce a value like temperature or presure or volume, …
function enforce(sim::MDSimulation)
    for callback in sim.enforces
        callback(sim.data)
    end
end

# Check the physical consistency of the simulation : number of particles is
# constant, global velocity is zero, …
function check(sim::MDSimulation)
    for callback in sim.checks
        callback(sim.data)
    end
end


# Compute values of interest : temperature, total energy, radial distribution
# functions, diffusion coefficients, …
function compute(sim::MDSimulation)
    for callback in sim.computes
        callback(sim.data)
    end
end

#TODO: find a way to link a compute and an output. A semi-global dict maybe ?

# Output data to files : trajectories, energy as function of time, …
function output(sim::MDSimulation)
    context = sim.data
    for output in sim.outputs
        write(output, context)
    end
end

include("UI.jl")
