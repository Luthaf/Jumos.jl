#===============================================================================
             Trajectories reading and writing through iterators
===============================================================================#
import Base: close, show
import Jumos: Frame

export Reader, Writer
export eachframe, read_next_frame!, read_frame!, opentraj


abstract TrajectoryIO

type TrajectoryIOError <: Exception
    message::String
end

function show(io::IO, e::TrajectoryIOError)
    show(io, e.message)
end


abstract AbstractReaderIO <: TrajectoryIO
type Reader{T<:AbstractReaderIO}
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

Frame(reader::Reader) = Frame(reader.topology)

abstract AbstractWriterIO <: TrajectoryIO
type Writer{T<:AbstractWriterIO}
    current_step::Int
    writer::T
end

Writer(IOWriter::AbstractWriterIO) = Writer(0, IOWriter)
Frame(writer::Writer) = Frame(writer.topology)

#===============================================================================
                Iterator interface for trajectories IO

All the new reader/writer should implement the following methods:

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

include("XYZ/Reader.jl")
include("XYZ/Writer.jl")

include("NetCDF/Reader.jl")
include("NetCDF/Writer.jl")

# Dispatcher opening a trajectory. Will return an object
# of type <TRAJ_TYPE><Reader|Writer>. The trajectory format is
# assumed from the extension.
function opentraj(filename; mode="r", kwargs...)
    extension = split(strip(filename), ".")[end]
    kwargs = Dict(convert(Array{(Symbol,Any), 1}, kwargs))
    if mode == "r"
        # TODO: Use a dict to associate extensions and Readers
        if extension == "xyz"
            info(".xyz extension, assuming XYZ trajectory")
            if !(haskey(kwargs, :cell))
                warn("No cell size while opening XYZ trajectories")
            end
            IOreader = XYZReader(filename, kwargs[:cell])
            return Reader(IOreader, filename)
        elseif extension == "nc"
            info(".nc extension, assuming NetCDF trajectory")
            topology = get(kwargs, :topology, "")
            IOreader = NCReader(filename)
            return Reader(IOreader, topology)
        else
            error("The '$extension' extension is not recognized")
        end
    elseif mode =="w"
        if extension == "xyz"
            info(".xyz extension, assuming XYZ trajectory")
            IOwriter = XYZWriter(filename)
            return Writer(IOwriter)
        else
            error("The '$extension' extension is not recognized")
        end
    else
        error("Only read ('r') and write ('w') modes are supported")
    end
end

Reader(filename::String; kwargs...) = opentraj(filename; mode="r", kwargs...)
Writer(filename::String; kwargs...) = opentraj(filename; mode="w", kwargs...)

close(traj::Reader) = close(traj.reader.file)
isopen(traj::Reader)= isopen(traj.reader.file)

close(traj::Writer) = close(traj.writer.file)
isopen(traj::Writer)= isopen(traj.writer.file)
