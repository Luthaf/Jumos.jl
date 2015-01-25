# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#           Enforcing various values : temperature, pressure, ...
# ============================================================================ #

import Base: call
export BaseControl
export BerendsenBarostat, WrapParticles
export BerendsenThermostat, VelocityRescaleThermostat

# abstract BaseControl -> Defined in MolecularDynamics.jl

function setup(::BaseControl, ::MolecularDynamic)
    return nothing
end

@doc "
Wrap all the particles in the simulation cell to prevent them from going out.
" ->
immutable WrapParticles <: BaseControl end

function call(::WrapParticles, sim::MolecularDynamic)
    @inbounds for i=1:size(sim.frame)
        sim.frame.positions[i] = minimal_image(sim.frame.positions[i], sim.cell)
    end
end

abstract Thermostat <: BaseControl

function setup(::Thermostat, sim::MolecularDynamic)
    if !have_compute(sim, TemperatureCompute)
        push!(sim.computes, TemperatureCompute())
    end
end

@doc doc"
Velocity rescaling thermostat. At each step, if the simulation temperature is
farther than the tolerance of the wanted temperature, all the velocities are
rescaled.

The main constructor is `VelocityRescaleThermostat(T0, tol)`.
" ->
immutable VelocityRescaleThermostat <: Thermostat
    T::Float64
    tol::Float64
end

function call(th::VelocityRescaleThermostat, sim::MolecularDynamic)
    T = sim.data[:temperature]
    if abs(T - th.T) > th.tol # Let's rescale the velocities
        @inbounds for i=1:size(sim.frame)
            sim.frame.velocities[i] *= sqrt(th.T/T)
        end
    end
    return nothing
end


@doc doc"
Berendsen thermostat, created by multiplicating the velocities by a factor $\lambda$:
$$ \lambda = \sqrt{ 1 + \frac{\Delta t}{\tau} \left(\frac{T_0}{T} \right) - 1}.$$

The main constructor is `BerendsenThermostat(T0, [tau = 100])`, where $\tau$ is
expressed in multiples of $\Delta t$. This assume a constant $\Delta t$.

The algorithm come from doi:10.1063/1.448118.
" ->
immutable BerendsenThermostat <: Thermostat
    T::Float64
    tau::Float64
end

BerendsenThermostat(T) = BerendsenThermostat(T, 100)

function call(th::BerendsenThermostat, sim::MolecularDynamic)
    T = sim.data[:temperature]
    λ = sqrt(1 + 1/th.tau*(th.T/T - 1))
    @inbounds for i=1:size(sim.frame)
        sim.frame.velocities[i] = sim.frame.velocities[i] .* λ
    end
end

immutable BerendsenBarostat <: BaseControl
    tau::Float64
end
