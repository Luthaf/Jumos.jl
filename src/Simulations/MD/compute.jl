#===============================================================================
                        Compute interesting values
===============================================================================#
import Base: call
using Jumos.Constants #kB

export BaseCompute
export TemperatureCompute, PressureCompute, VolumeCompute

# abstract BaseCompute -> Defined in MolecularDynamics.jl

@doc "
Compute the temperature of a simulation frame using the relation
	T = 1/kB * 2K/(3N) with K = ∑ 1/2 m_i \vec v_i^2
" ->
type TemperatureCompute <: BaseCompute
end

function call(::TemperatureCompute, sim::MDSimulation)
	T = 0.0
	K = 0.0
	natoms = size(sim.frame)
	@inbounds for i=1:natoms
		K += 0.5 * sim.masses[i] * dot(sim.frame.velocities[i], sim.frame.velocities[i])
	end
	T = 1/kB * 2*K/(3*natoms)
	sim.data[:temperature] = T
	return T
end

type PressureCompute <: BaseCompute

end

type VolumeCompute <: BaseCompute

end
