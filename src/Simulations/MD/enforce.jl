# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#           Enforcing various values : temperature, pressure, ...
# ============================================================================ #

import Base: call
export BaseEnforce, BerendsenBarostat, BerendsenThermostat, WrapParticles

# abstract BaseEnforce -> Defined in MolecularDynamics.jl

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
