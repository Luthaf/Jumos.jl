#===============================================================================
            Enforcing various values : temperature, pressure, …
===============================================================================#
import Base: call
export BaseEnforce, BerendsenBarostat, BerendsenThermostat, WrapParticle

abstract BaseEnforce

@doc "
Wrap all the particles in the simulation cell to prevent them from going out.
" ->
type WrapParticles <: BaseEnforce
end

function call(::WrapParticles, frame::Frame)
    @inbounds for i=1:size(frame)
        frame.positions[i] = minimal_image(frame.positions[i], frame.cell)
    end
end

type BerendsenThermostat <: BaseEnforce
    tau::Float64
end

type BerendsenBarostat <: BaseEnforce
    tau::Float64
end
