#===============================================================================
                    Checking the simulation consistency
===============================================================================#
export BaseCheck, ParticleNumberIsConstant, GlobalVelocityIsNull, TotalForceIsNull
abstract BaseCheck

type ParticleNumberIsConstant <: BaseCheck
end

type GlobalVelocityIsNull <: BaseCheck
end

type TotalForceIsNull <: BaseCheck
end
