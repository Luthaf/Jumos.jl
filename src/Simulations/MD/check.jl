#===============================================================================
                    Checking the simulation consistency
===============================================================================#
import Base: show, call
export BaseCheck
export ParticleNumberIsConstant, GlobalVelocityIsNull, TotalForceIsNull
# abstract BaseCheck -> Defined in MolecularDynamics.jl

type ParticleNumberIsConstant <: BaseCheck
end

type GlobalVelocityIsNull <: BaseCheck
end

type TotalForceIsNull <: BaseCheck
end
