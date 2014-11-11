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

    # Maybe store the masses somewhere to prevent this from being rerun at
    # every step.
    masses = atomic_masses(data.topology)
    check_masses(masses, data.topology)

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

function check_masses(masses, topology::Topology)
    if countnz(masses) != size(topology)
        bad_masses = Set()
        for (i, val) in enumerate(A)
            if val == 0.0
                union!(bad_masses, [topology.atoms[i].name])
            end
        end
        missing = join(bad_masses, " ")
        throw(SimulationConfigurationError(
                "Missing masses for the following atomic types: $missing"
            ))
    end
end
