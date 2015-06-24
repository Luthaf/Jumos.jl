# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#           Enforcing various values : temperature, pressure, ...
# ============================================================================ #

# abstract Control -> Defined in Simulation.jl
export Control
export WrapParticles
export BerendsenThermostat, VelocityRescaleThermostat
# export BerendsenBarostat

function setup(::Control, ::Simulation)
    return nothing
end

# ============================================================================ #

@doc "
Wrap all the particles in the simulation cell to prevent them from going out.
" ->
immutable WrapParticles <: Control end

function Base.call(::WrapParticles, univ::Universe)
    for i=1:size(univ.frame)
        @inbounds minimal_image!(univ.frame.positions[i], univ.cell)
    end
end

# ============================================================================ #

abstract Thermostat <: Control

function setup(::Thermostat, sim::Simulation)
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

function Base.call(th::VelocityRescaleThermostat, univ::Universe)
    T = univ.data[:temperature]
    if abs(T - th.T) > th.tol # Let's rescale the velocities
        for i=1:size(univ), dim=1:3
            @inbounds univ.frame.velocities[dim, i] *= sqrt(th.T/T)
        end
    end
end

# ============================================================================ #

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

function Base.call(th::BerendsenThermostat, univ::Universe)
    T = univ.data[:temperature]
    λ = sqrt(1 + 1/th.tau*(th.T/T - 1))
    for i=1:size(univ), dim=1:3
        @inbounds univ.frame.velocities[dim, i] *= λ
    end
end

# ============================================================================ #

#immutable BerendsenBarostat <: Control
#    tau::Float64
#end
