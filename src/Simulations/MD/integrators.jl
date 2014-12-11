#===============================================================================
                    Time integration takes place here
===============================================================================#
export BaseIntegrator

export VelocityVerlet, Verlet
# abstract BaseIntegrator -> Defined in MolecularDynamics.jl

@doc "
Velocity Verlet integrator
" ->
type VelocityVerlet <: BaseIntegrator
    timestep::Float64
    accelerations::Array3D
end

function VelocityVerlet(timestep::Float64)
    accelerations = Array3D(Float64, 0)
    return VelocityVerlet(timestep, accelerations)
end

function call(integrator::VelocityVerlet, frame::Frame, masses::Vector{Float64}, forces::Array3D)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = frame.positions
    velocities = frame.velocities
    accelerations = integrator.accelerations

    natoms = size(frame)

    if length(accelerations) != natoms
        integrator.accelerations = resize(accelerations, natoms)
        accelerations = integrator.accelerations
        # re-initialize the accelerations
        for i=1:natoms
            accelerations[i] = zeros(Float32, 3)
        end
    end

    # Update positions at t + ∆t
    @inbounds for i=1:natoms
        positions[i] .+= velocities[i].*dt .+ 0.5.*accelerations[i].*dt^2
    end

    # Update velocities at t + ∆t/2
    @inbounds for i=1:natoms
        velocities[i] .+= 0.5.*accelerations[i].*dt
    end

    # Update accelerations at t + ∆t
    @inbounds for i=1:natoms
        accelerations[i] = forces[i] ./ masses[i]
    end

    # Update velocities at t + ∆t
    @inbounds for i=1:natoms
        velocities[i] .+= 0.5.*accelerations[i].*dt
    end
end


@doc "
Basic Verlet integrator. Velocities are updated at t + 1/2 ∆t
" ->
type Verlet <: BaseIntegrator
    timestep::Float64
    prevpos::Array3D # Previous positions
end

function Verlet(timestep::Float64)
    prevpos = Array3D(Float64, 0)
    return Verlet(timestep, prevpos)
end

function call(integrator::Verlet, frame::Frame, masses::Vector{Float64}, forces::Array3D)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = frame.positions
    velocities = frame.velocities
    prevpos = integrator.prevpos

    natoms = size(sim.frame)

    if length(prevpos) != natoms
        integrator.prevpos = resize(prevpos, natoms)
        prevpos = integrator.prevpos
        # re-initialize the previous positions
        for i=1:natoms
            prevpos[i] = zeros(Float32, 3)
        end
    end

    current = copy(prevpos)

    # Save current positions
    @inbounds for i=1:natoms
        current[i] = positions[i]
    end

    # Update positions
    @inbounds for i=1:natoms
        positions[i] = sim.forces[i] .* dt^2/sim.masses[i] .+ 2.0 .* positions[i] .- prevpos[i]
    end

    # Update saved position
    @inbounds for i=1:natoms
        prevpos[i] = current[i]
    end

    # Update velocities
    @inbounds for i=1:natoms
        velocities[i] = (positions[i] .- prevpos[i]) ./ dt
    end
end
