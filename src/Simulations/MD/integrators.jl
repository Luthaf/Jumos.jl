#===============================================================================
                    Time integration takes place here
===============================================================================#

abstract BaseIntegrator

immutable VelocityVerlet <: BaseIntegrator
    timestep::Float64
end

function call(i::VelocityVerlet, data::Frame)
    const dt = i.timestep
end
