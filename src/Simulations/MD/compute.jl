# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Compute interesting values
# ============================================================================ #

import Base: call
using Jumos.Constants #kB

export BaseCompute
export TemperatureCompute, PressureCompute, VolumeCompute, EnergyCompute
# TODO: make these types imutables ?

# abstract BaseCompute -> Defined in MolecularDynamics.jl

@doc "
Compute the temperature of a simulation frame using the relation
	T = 1/kB * 2K/(3N) with K the kinetic energy
" ->
type TemperatureCompute <: BaseCompute end

function call(::TemperatureCompute, sim::MolecularDynamic)
	T = 0.0
    K = kinetic_energy(sim)*1e-4
    natoms = size(sim.frame)
	T = 1/kB * 2*K/(3*natoms)
	sim.data[:temperature] = T
	return T
end


@doc "
Compute the pressure of the system.
" ->
type PressureCompute <: BaseCompute

end

@doc "
Compute the volume of the current simulation cell
" ->
type VolumeCompute <: BaseCompute end

function call(::VolumeCompute, sim::MolecularDynamic)
    V = volume(sim.frame.cell)
    sim.data[:volume] = V
    return V
end


@doc "
Compute the energy of a simulation.
    EnergyCompute()(simulation::MolecularDynamic) returns a tuple
    (Kinetic_energy, Potential_energy, Total_energy)
" ->
type EnergyCompute <: BaseCompute end

function call(::EnergyCompute, sim::MolecularDynamic)
    K = kinetic_energy(sim)
    P = potential_energy(sim)
	sim.data[:E_kinetic] = K
    sim.data[:E_potential] = P
    sim.data[:E_total] = P + K
	return K, P, P + K
end

function kinetic_energy(sim::MolecularDynamic)
    K = 0.0
	natoms = size(sim.frame)
	@inbounds for i=1:natoms
		K += 0.5 * sim.masses[i] * dot(sim.frame.velocities[i], sim.frame.velocities[i])
	end
    return K*1e4  # TODO: better handling of energy conversions
end

function potential_energy(sim::MolecularDynamic)
    E = 0.0
	natoms = size(sim.frame)
	@inbounds for i=1:natoms, j=(i+1):natoms
        atom_i = sim.frame.topology.atoms[i]
        atom_j = sim.frame.topology.atoms[j]
        potential = sim.interactions[(atom_i, atom_j)]
		E += potential(distance(sim.frame, i, j))
	end
    return E
end
