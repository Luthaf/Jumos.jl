#===============================================================================
            Enforcing various values : temperature, pressure, …
===============================================================================#

abstract BaseEnforce

type BerendsenThermostat <: BaseEnforce
    tau::Float64
end

type BerendsenBarostat <: BaseEnforce
    tau::Float64
end
