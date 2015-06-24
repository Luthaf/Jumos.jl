# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                              Frame type
# ============================================================================ #

export Frame, set_frame_size!

@doc "
The type Frame holds the variables data from a simulation, i.e the current step,
the positions and the velocities.
" ->
type Frame
    positions::Array3D
    velocities::Array3D
    step::Int64
end

Frame(natoms) = Frame(Array3D(Float64, natoms), Array3D(Float64, 0), 0)
Frame() = Frame(0)
Base.size(frame::Frame) = length(frame.positions)

function set_frame_size!(frame::Frame, wanted_size::Integer; velocities=false)
    if size(frame) != wanted_size
        frame.positions = Array3D(Float64, wanted_size)
        if velocities || length(frame.velocities) != 0
            frame.velocities = Array3D(Float64, wanted_size)
        end
    end
    return frame
end
