#===============================================================================
             Trajectories reading and writing through iterators
===============================================================================#

# Trajectory types
abstract MDTrajectory
abstract TrajectoryIO

# Exceptions types
type TrajectoryIOError <: Exception
    message::String
end
type NotImplementedError <: Exception
    message::String
end

function show(io::IO, e::NotImplementedError)
    show(io, "Not implemented : $(e.message)")
end
function show(io::IO, e::TrajectoryIOError)
    show(io, e.message)
end


abstract AbstractReaderIO <: TrajectoryIO
type Reader{T<:AbstractReaderIO} <: MDTrajectory
    natoms::Int
    nsteps::Int
    current_step::Int
    topology::Topology
    reader::T
end

function Reader(r::AbstractReaderIO, topology_filename="")
    natoms, nsteps = get_traj_infos(r)
    if topology_filename != ""
        topology = Topology(topology_filename)
    else
        info("You may want to use atomic names, providing a topology file")
    end
    return Reader(natoms, nsteps, 0, topology, r)
end

abstract AbstractWriterIO <: TrajectoryIO
type Writer <: MDTrajectory
end


# Simulation box type
immutable SimBox
    length :: Vect3D{Float64}
    angles :: Vect3D{Float64}
    box_type :: Symbol  # box_type should takes only the values :triclinic and :orthorombic
end

function getindex(b::SimBox, i::Union(Integer, String))
    if isa(i, Integer) && 0 < i <= 3
        return b.length[i]
    elseif isa(i, Integer) && 3 < i <= 6
        return b.angles[i-3]
    elseif isa(i, String)
        if lower(i) == "x"
            return b.length[1]
        elseif lower(i) == "y"
            return b.length[2]
        elseif lower(i) == "z"
            return b.length[3]
        elseif lower(i) == "alpha"
            return b.angles[1]
        elseif lower(i) == "beta"
            return b.angles[2]
        elseif lower(i) == "gamma"
            return b.angles[3]
        end
    end
    throw(BoundsError())
end

function SimBox(u::Vect3D, v::Vect3D)
    if v == vect3d(90.0)
        box_type = :orthorombic
    else
        box_type = :triclinic
    end
    return SimBox(u, v, box_type)
end

SimBox(u::Vector, v::Vector) = SimBox(vect3d(u), vect3d(v))
SimBox(u::Vect3D) = SimBox(u, vect3d(90.0))

function SimBox(u::Vector)
    if length(u) == 3
        return SimBox(vect3d(u))
    elseif length(u) == 6
        return SimBox(vect3d(u[1:3]), vect3d(u[4:6]))
    else
        throw(InexactError())
    end
end

SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real) = SimBox(vect3d(Lx, Ly, Lz), vect3d(a, b, c))
SimBox(Lx::Real, Ly::Real, Lz::Real) = SimBox(vect3d(Lx, Ly, Lz))
SimBox(L::Real) = SimBox(L, L, L)
SimBox() = SimBox(0.0)

SimBox(b::SimBox) = b


# The Frame type holds a frame, i.e. one step of a simulation.
type Frame
    step::Integer
    box::SimBox
    topology::Topology
    positions::Vector{Vect3D{Float32}}
    velocities::Vector{Vect3D{Float32}}
end

Frame(t::Topology) = Frame(0,
                           SimBox(),
                           t,
                           Array(Vect3D{Float32}, size(t.atoms, 1)),
                           Array(Vect3D{Float32}, size(t.atoms, 1)),
                           )

Frame(t::MDTrajectory) = Frame(t.topology)


#===============================================================================
                    Iterator interface for trajectories

All the new trajectory reader should implement the following methods:

    - read_next_frame!(t::Reader, f::Frame)
        Reads the next frame in f if their is one, update t.current_step.
        Raise an error in case of failure
        Return true if their is some other frame to read, false otherwise
    - read_frame!(t::Reader, step::Integer, f::Frame)
        Reads the frame at step "step" and update t.current_step
        Raise an error in the case of failure
        Return true if their is a frame after the step "step", false otherwise
===============================================================================#

# Only reads some specific steps
function eachframe(t::Reader, range::Range{Integer})
    frame = Frame(t)
    function _it()
        for i in range
            read_frame!(t, i, frame)
            produce(frame)
        end
    end
    return Task(_it)
end

# Reads every steps of a trajectory, given a starting point
function eachframe(t::Reader; start=1)
    t.current_step = start - 1
    frame = Frame(t)
    function _it()
        while read_next_frame!(t, frame)
            produce(frame)
        end
    end
    return Task(_it)
end

function read_next_frame!{T<:AbstractReaderIO}(t::Reader{T}, f::Frame)
   throw(NotImplementedError("Method read_next_frame! not implemented for "*
                             "$(typeof(t.reader)) trajectory type"))
end

function read_frame!{T<:AbstractReaderIO}(t::Reader{T}, step::Integer, f::Frame)
    throw(NotImplementedError("Method read_frame! not implemented for "*
                              "$(typeof(t.reader)) trajectory type"))
end

#===============================================================================
                            Trajectory formats
===============================================================================#

include("Trajectories/XYZ/Reader.jl")
include("Trajectories/XYZ/Writer.jl")

include("Trajectories/NetCDF/Reader.jl")
include("Trajectories/NetCDF/Writer.jl")

# Dispatcher opening a trajectory. Will return an object
# of type <TRAJ_TYPE><Reader|Writer>. The trajectory format is
# assumed from the extension.
function opentraj(filename; mode="r", kwargs...)
    extension = split(strip(filename), ".")[end]
    kwargs = Dict(convert(Array{(Symbol,Any), 1}, kwargs))
    if mode == "r"
        if extension == "xyz"
            info(".xyz extension, assuming XYZ trajectory")
            if !(haskey(kwargs, :box))
                warn("No box size while opening XYZ trajectories")
            end
            IOreader = XYZReader(filename, kwargs[:box])
            return Reader(IOreader, filename)
        elseif extension == "nc"
            info(".nc extension, assuming NetCDF trajectory")
            topology = get(kwargs, :topology, "")
            IOreader = NCReader(filename)
            return Reader(IOreader, topology)
        else
            error("The '$extension' extension is not recognized")
        end
    else
        error("Only read mode is supported")
    end
end

Reader(filename::String; kwargs...) = opentraj(filename; mode="r", kwargs...)

close(traj::Reader) = close(traj.reader.file)
isopen(traj::Reader)= isopen(traj.reader.file)
