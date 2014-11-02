#===============================================================================
                    The Frame type holds a frame,
            i.e. all the data form one step of a simulation.
===============================================================================#
import Base: size
export Frame

type Frame
    step::Integer
    box::SimBox
    topology::Topology
    positions::Vector{Vect3D{Float32}}
    velocities::Nullable{Vector{Vect3D{Float32}}}
    forces::Nullable{Vector{Vect3D{Float32}}}
end

Frame(t::Topology) = Frame(0,
                           SimBox(),
                           t,
                           Array(Vect3D{Float32}, size(t.atoms)),
                           Nullable{Vector{Vect3D{Float32}}}(),
                           Nullable{Vector{Vect3D{Float32}}}(),
                           )

size(f::Frame) = size(f.positions, 1)
