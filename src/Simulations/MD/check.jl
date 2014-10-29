#===============================================================================
                    Checking the simulation consistency
===============================================================================#

abstract BaseCheck

type ParticleNumberIsConstant <: BaseCheck
end

type GlobalVelocityIsNull <: BaseCheck
end

type TotalForceIsNull <: BaseCheck
end
