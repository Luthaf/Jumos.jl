# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Compute interesting values
# ============================================================================ #

using Jumos.Constants #kB

# abstract Compute -> Defined in Simulations.jl
export Compute
export TemperatureCompute, VolumeCompute, EnergyCompute
#export PressureCompute

function have_compute{T<:Compute}(sim::Simulation, compute_type::Type{T})
	for compute in sim.computes
		if isa(compute, compute_type)
			return true
		end
	end
	return false
end

# ============================================================================ #

@doc "
Compute the temperature of a simulation frame using the relation
	T = 1/kB * 2K/(3N) with K the kinetic energy
" ->
immutable TemperatureCompute <: Compute end

function Base.call(::TemperatureCompute, univ::Universe)
	T = 0.0
    K = kinetic_energy(univ)
    natoms = size(univ.frame)
	T = 1/kB * 2*K/(3*natoms)
	univ.data[:temperature] = T
	return T
end

# ============================================================================ #

#@doc "
#Compute the pressure of the system.
#" ->
#immutable PressureCompute <: Compute end

# ============================================================================ #

@doc "
Compute the volume of the current simulation cell
" ->
immutable VolumeCompute <: Compute end

function Base.call(::VolumeCompute, univ::Universe)
    V = volume(univ.cell)
	univ.data[:volume] = V
    return V
end

# ============================================================================ #

@doc "
Compute the energy of a simulation.
    EnergyCompute()(simulation::MolecularDynamic) returns a tuple
    (Kinetic_energy, Potential_energy, Total_energy)
" ->
immutable EnergyCompute <: Compute end

function Base.call(::EnergyCompute, univ::Universe)
    K = kinetic_energy(univ)
    P = potential_energy(univ)
	univ.data[:E_kinetic] = K
	univ.data[:E_potential] = P
	univ.data[:E_total] = P + K
	return K, P, P + K
end

function kinetic_energy(univ::Universe)
    K = 0.0
	const natoms = size(univ)
	@inbounds for i=1:natoms
		K += 0.5 * univ.masses[i] * norm2(univ.frame.velocities[i])
	end
    return K
end

function potential_energy(univ::Universe)
    E = 0.0
	const natoms = size(univ)
	@inbounds for i=1:natoms, j=(i+1):natoms
        atom_i = univ.topology.atoms[i]
        atom_j = univ.topology.atoms[j]
		for potential in pairs(univ.interactions, atom_i, atom_j)
			E += potential(distance(univ, i, j))
		end
		# TODO: bonds, angles, ...
	end
    return E
end
