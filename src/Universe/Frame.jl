#===============================================================================
                    The Frame type holds a frame,
            i.e. all the data form one step of a simulation.
===============================================================================#
import Base: size
export Frame

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
