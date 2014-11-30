#===============================================================================
                    The Frame type holds a frame,
            i.e. all the data from one step of a simulation.
===============================================================================#
import Base: size
export Frame, set_frame_size!

# TODO: use Array3D with size of 0 instead ?
NullableArray3D = Union(Void, Array3D)

type Frame
    step::Integer
    box::SimBox
    topology::Topology
    positions::Array3D
    velocities::NullableArray3D
end

Frame(t::Topology) = Frame(0,
                           SimBox(),
                           t,
                           Array3D(Float32, size(t.atoms, 1)),
                           nothing)

# Empty frame construction
Frame() = Frame(0,SimBox(), Topology(), Array3D(Float64, 0), nothing)

size(f::Frame) = size(f.positions, 1)


function set_frame_size!(frame::Frame, wanted_size::Integer)
    if size(frame) != wanted_size
        frame.positions = Array3D(Float32, wanted_size)
        if frame.velocities != nothing
            frame.velocities = Array3D(Float32, wanted_size)
        end
    end
    return frame
end
