#===============================================================================
                        Compute interesting values
===============================================================================#
export BaseCompute, ComputeTemperature, ComputeVolume, ComputePressure
abstract BaseCompute

type ComputeTemperature <: BaseCompute

end

type ComputePressure <: BaseCompute

end

type ComputeVolume <: BaseCompute

end
