# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                   Time integration takes place here
# ============================================================================ #

export BaseIntegrator

export VelocityVerlet, Verlet
# abstract BaseIntegrator -> Defined in MolecularDynamics.jl

function setup(::BaseIntegrator, ::MolecularDynamic) end

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

function setup(integrator::VelocityVerlet, sim::MolecularDynamic)
    natoms = size(sim.frame)
    if length(integrator.accelerations) != natoms
        integrator.accelerations = resize(integrator.accelerations, natoms)
        # re-initialize the accelerations
        for i=1:natoms
            integrator.accelerations[i] = zeros(Float64, 3)
        end
    end
end

function call(integrator::VelocityVerlet, sim::MolecularDynamic)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = sim.frame.positions
    velocities = sim.frame.velocities
    accelerations = integrator.accelerations
    masses = sim.masses

    natoms = size(sim.frame)

    # Update positions at t + ∆t
    @inbounds for i=1:natoms
        positions[i] .+= velocities[i].*dt .+ 0.5.*accelerations[i].*dt^2
    end

    # Update velocities at t + ∆t/2
    @inbounds for i=1:natoms
        velocities[i] .+= 0.5.*accelerations[i].*dt
    end

    get_forces!(sim)

    # Update accelerations at t + ∆t
    @inbounds for i=1:natoms
        accelerations[i] = sim.forces[i] ./ masses[i]
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
    tmp::Array3D     # Temporary array for computations
    prevpos::Array3D # Previous positions
    wrap_velocities::Bool
end

function Verlet(timestep::Float64)
    return Verlet(timestep, Array3D(Float64, 0), Array3D(Float64, 0), false)
end

function setup(integrator::Verlet, sim::MolecularDynamic)
    natoms = size(sim.frame)

    integrator.wrap_velocities = ispresent(sim, WrapParticles)

    if length(integrator.prevpos) != natoms || length(integrator.tmp) != natoms
        integrator.prevpos = resize(integrator.prevpos, natoms)
        integrator.tmp = resize(integrator.tmp, natoms)
        # re-initialize the arrays
        for i=1:natoms
            integrator.tmp[i] = zeros(Float64, 3)
        end

        dt = integrator.timestep
        get_forces!(sim)
        # Approximate the positions at t - ∆t
        for i=1:natoms
            integrator.prevpos[i] = sim.frame.positions[i] - sim.frame.velocities[i].*dt
        end
    end
end

function call(integrator::Verlet, sim::MolecularDynamic)
    const dt = integrator.timestep

    # Getting pointers to facilitate further reading
    positions = sim.frame.positions
    velocities = sim.frame.velocities
    prevpos = integrator.prevpos
    tmp = integrator.tmp
    masses = sim.masses

    natoms = size(sim.frame)
    get_forces!(sim)

    # Save positions at t
    @inbounds for i=1:natoms
        tmp[i] = positions[i]
    end

    # Update positions at t + ∆t
    @inbounds for i=1:natoms
        t = 2.0 .* positions[i] - prevpos[i] + (dt^2 / masses[i]) .* sim.forces[i]
        positions[i] = t
    end

    # Update velocities at t
    if integrator.wrap_velocities
        # If the postions are wrapped, position is updated, but not prevpos
        @inbounds for i=1:natoms
            velocities[i] = minimal_image(positions[i] - prevpos[i], sim.frame.cell) ./ (2.0 * dt)
        end
    else
        @inbounds for i=1:natoms
            velocities[i] = (positions[i] - prevpos[i]) ./ (2.0 * dt)
        end
    end


    # Update saved position
    @inbounds for i=1:natoms
        prevpos[i] = tmp[i]
    end
end
