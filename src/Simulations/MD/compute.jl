#===============================================================================
                        Compute interesting values
===============================================================================#
import Base: call
using Jumos.Constants #kB

export BaseCompute
export TemperatureCompute, PressureCompute, VolumeCompute, EnergyCompute

# abstract BaseCompute -> Defined in MolecularDynamics.jl

@doc "
Compute the temperature of a simulation frame using the relation
	T = 1/kB * 2K/(3N) with K = ∑ 1/2 m_i \vec v_i^2
" ->
type TemperatureCompute <: BaseCompute
end

function call(::TemperatureCompute, sim::MDSimulation)
	T = 0.0
    K = kinetic_energy(sim)*1e-4
    natoms = size(sim.frame)
	T = 1/kB * 2*K/(3*natoms)
	sim.data[:temperature] = T
	return T
end

type PressureCompute <: BaseCompute

end

type VolumeCompute <: BaseCompute

end

type EnergyCompute <: BaseCompute end

function call(::EnergyCompute, sim::MDSimulation)
    K = kinetic_energy(sim)
    P = potential_energy(sim)
	sim.data[:E_kinetic] = K
    sim.data[:E_potential] = P
    sim.data[:E_total] = P + K
	return K, P, P + K
end

function kinetic_energy(sim::MDSimulation)
    K = 0.0
	natoms = size(sim.frame)
	@inbounds for i=1:natoms
		K += 0.5 * sim.masses[i] * dot(sim.frame.velocities[i], sim.frame.velocities[i])
	end
    return K*1e4  # TODO: better handling of energy conversions
end

function potential_energy(sim::MDSimulation)
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
