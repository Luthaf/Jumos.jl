#===============================================================================
                    The Frame type holds a frame,
            i.e. all the data from one step of a simulation.
===============================================================================#
import Base: size
export Frame, set_frame_size!

type Frame
    step::Integer
    box::SimBox
    topology::Topology
    positions::Array3D
    velocities::Array3D
end

Frame(t::Topology) = Frame(0,
                           SimBox(),
                           t,
                           Array3D(Float32, size(t.atoms, 1)),
                           Array3D(Float32, 0))

# Empty frame construction
Frame() = Frame(0,SimBox(), Topology(), Array3D(Float64, 0), Array3D(Float32, 0))

size(f::Frame) = length(f.positions)


function set_frame_size!(frame::Frame, wanted_size::Integer; velocities=false)
    if size(frame) != wanted_size
        frame.positions = Array3D(Float32, wanted_size)
        if velocities || length(frame.velocities) != 0
            frame.velocities = Array3D(Float32, wanted_size)
        end
    end
    return frame
end
