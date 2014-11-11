#===============================================================================
                    Time integration takes place here
===============================================================================#
export BaseIntegrator, VelocityVerlet
abstract BaseIntegrator

immutable VelocityVerlet <: BaseIntegrator
    timestep::Float64
end

function call(i::VelocityVerlet, data::Frame)
    const dt = i.timestep

    # Update positions at t + ∆t
    @inbounds for i=1:size(data)
        data.positions[i] += data.velocities[i].*dt + 0.5.*data.accelerations[i].*dt*dt
    end

    # Update velocities at t + ∆t/2
    @inbounds for i=1:size(data)
        data.velocities[i] += 0.5.*data.accelerations[i].*dt
    end

    # Update accelerations at t + ∆t
    @inbounds for i=1:size(data)
        data.accelerations[i] = 1/masses[i] .* data.forces[i]
    end

    # Update velocities at t + ∆t
    @inbounds for i=1:size(data)
        data.velocities[i] += 0.5 .* data.accelerations[i] .* dt
    end
end
