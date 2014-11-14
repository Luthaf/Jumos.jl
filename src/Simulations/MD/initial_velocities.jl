#===============================================================================
                            Initialize velocities
===============================================================================#

export create_velocities

const kB = 3.0 # Todo: real value in internal units

function create_velocities(sim::MDSimulation, temp::Integer; initializer="boltzman")
    # Allocate the velocity array
    sim.data.velocities = Array(Vect3D{Float32}, size(sim.data))

    function_name = "init_" * initializer * "_velocities"
    funct = eval(symbol(function_name))

    # Get masses for the simulation
    sim.masses = atomic_masses(sim.topology)
    check_masses(sim)

    return funct(sim, temp)
end

function init_boltzman_velocities(sim::MDSimulation, temp::Integer)
    velocities = sim.data.velocities
    masses = sim.masses
    @inbounds for i=1:size(sim.data)
        velocities[i] = vect3d(rand_vel_boltzman(masses[i], temp)...)
    end
end

@inline function rand_vel_boltzman(m, T)
    return sqrt(kB*T/m)*randn(3)
end

function init_random_velocities(sim::MDSimulation, temp::Integer)
    velocities = sim.data.velocities
    @inbounds for i=1:size(sim.data)
        velocities[i] = vect3d(rand_vel()...)
    end
end

@inline function rand_vel()
    return 2.*rand(3) .- 1
end
