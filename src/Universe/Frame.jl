#===============================================================================
                    The Frame type holds a frame,
            i.e. all the data form one step of a simulation.
===============================================================================#
import Base: size
export Frame, set_frame_size!

Array3D = Vector{Vect3D{Float32}}
NullableArray3D = Union(Void, Array3D)

type Frame
    step::Integer
    box::SimBox
    topology::Topology
    positions::Array3D
    velocities::NullableArray3D
    accelerations::NullableArray3D
    forces::NullableArray3D
end

Frame(t::Topology) = Frame(0,
                           SimBox(),
                           t,
                           Array(Vect3D{Float32}, size(t.atoms)),
                           nothing,
                           nothing,
                           nothing
                           )

# Empty frame construction
Frame() = Frame(0,SimBox(), Topology(), Vect3D{Float32}[], nothing, nothing, nothing)

size(f::Frame) = size(f.positions, 1)


function set_frame_size!(frame::Frame, wanted_size::Integer)
    if size(frame) == wanted_size
        return frame
    else
        resize!(frame.positions, wanted_size)
        for field in [:velocities, :accelerations, :forces]
            if getfield(frame, field) != nothing
                resize!(getfield(frame, field), wanted_size)
            end
        end
        return frame
    end
end
