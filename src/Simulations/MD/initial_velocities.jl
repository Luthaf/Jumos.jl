#===============================================================================
                            Initialize velocities
===============================================================================#
using Jumos.Constants: kB
export create_velocities

function create_velocities(sim::MDSimulation, temp::Integer; initializer="boltzman")
    # Allocate the velocity array
    sim.frame.velocities = Array3D(Float32, size(sim.frame))

    function_name = "init_" * initializer * "_velocities"
    funct = eval(symbol(function_name))

    # Get masses for the simulation
    sim.masses = atomic_masses(sim.topology)
    check_masses(sim)

    return funct(sim, temp)
end

function init_boltzman_velocities(sim::MDSimulation, temp::Integer)
    velocities = sim.frame.velocities
    masses = sim.masses
    @inbounds for i=1:size(sim.frame)
        velocities[i] = rand_vel_boltzman(masses[i], temp)
    end
end

@inline function rand_vel_boltzman(m, T)
    return sqrt(kB*T/m)*randn(3)
end

function init_random_velocities(sim::MDSimulation, temp::Integer)
    velocities = sim.frame.velocities
    @inbounds for i=1:size(sim.frame)
        velocities[i] = rand_vel()
    end
end

@inline function rand_vel()
    return 2.*rand(3) .- 1
end
