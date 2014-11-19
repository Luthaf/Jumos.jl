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

function call(integrator::VelocityVerlet, frame::Frame, masses::Vector{Float64}, forces::Array3D)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = frame.positions
    velocities = frame.velocities
    accelerations = integrator.accelerations

    natoms = size(frame)

    if size(positions, 1) != size(accelerations, 1)
        resize!(accelerations, size(positions, 1))
        # initialize the accelerations
        for i=1:natoms
            accelerations[i] = vect3d()
        end
    end

    # Update positions at t + ∆t
    @inbounds for i=1:natoms
        positions[i] += velocities[i]*dt + 0.5*accelerations[i]*dt^2
    end

    # Update velocities at t + ∆t/2
    @inbounds for i=1:natoms
        velocities[i] += 0.5*accelerations[i]*dt
    end

    # Update accelerations at t + ∆t
    @inbounds for i=1:natoms
        accelerations[i] = 1/masses[i]*forces[i]
    end

    # Update velocities at t + ∆t
    @inbounds for i=1:natoms
        velocities[i] += 0.5*accelerations[i]*dt
    end
end
