# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                              Frame type
# ============================================================================ #

import Base: size
export Frame, set_frame_size!

@doc "
The Frame type holds a frame,
i.e. all the data from one step of a simulation.
" ->
type Frame
    step::Integer
    cell::UnitCell
    topology::Topology
    positions::Array3D
    velocities::Array3D
end

Frame(topology::Topology) = Frame(1, UnitCell(), topology, Array3D(Float64, size(topology)), Array3D(Float64, 0))

# Empty frame construction
Frame() = Frame(1, UnitCell(), Topology(), Array3D(Float64, 0), Array3D(Float64, 0))

size(frame::Frame) = length(frame.positions)


function set_frame_size!(frame::Frame, wanted_size::Integer; velocities=false)
    if size(frame) != wanted_size
        frame.positions = Array3D(Float64, wanted_size)
        if velocities || length(frame.velocities) != 0
            frame.velocities = Array3D(Float64, wanted_size)
        end
    end
    return frame
end
