#===============================================================================
                    Time integration takes place here
===============================================================================#
export BaseIntegrator, VelocityVerlet
abstract BaseIntegrator

type VelocityVerlet <: BaseIntegrator
    timestep::Float64
    accelerations::Array3D
end

function VelocityVerlet(timestep::Float64)
    accelerations = Vect3D{Float32}[]
    return VelocityVerlet(timestep, accelerations)
end

function call(integrator::VelocityVerlet, data::Frame, forces::Array3D)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = data.positions
    velocities = data.velocities
    accelerations = integrator.accelerations

    if size(positions) != size(accelerations, 1)
        resize!(accelerations, size(positions))
    end

    # Update positions at t + ∆t
    @inbounds for i=1:size(data)
        positions[i] += velocities[i]*dt + 0.5*accelerations[i]*dt^2
    end

    # Update velocities at t + ∆t/2
    @inbounds for i=1:size(data)
        velocities[i] += 0.5*accelerations[i]*dt
    end

    # Update accelerations at t + ∆t
    @inbounds for i=1:size(data)
        accelerations[i] = 1/masses[i]*forces[i]
    end

    # Update velocities at t + ∆t
    @inbounds for i=1:size(data)
        velocities[i] += 0.5*accelerations[i]*dt
    end
end
