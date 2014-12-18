# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#            Trajectories reading and writing through iterators
# ============================================================================ #

import Base: close, show

export Reader, Writer
export eachframe, read_next_frame!, read_frame!, opentraj
export register_reader, register_writer

abstract TrajectoryIO

type TrajectoryIOError <: Exception
    message::String
end

function show(io::IO, e::TrajectoryIOError)
    show(io, e.message)
end


abstract FormatReader <: TrajectoryIO
type Reader{T<:FormatReader}
    natoms::Int
    nsteps::Int
    current_step::Int
    topology::Topology
    reader::T
end

function Reader(r::FormatReader, topology=Topology())
    natoms, nsteps = get_traj_infos(r)
    if natoms > 0 && size(topology) == 0
        topology = dummy_topology(natoms)
    end
    return Reader(natoms, nsteps, 0, topology, r)
end

import Jumos: Frame
Frame(reader::Reader) = Frame(reader.topology)

abstract FormatWriter <: TrajectoryIO
type Writer{T<:FormatWriter}
    current_step::Int
    writer::T
end

Writer(IOWriter::FormatWriter) = Writer(0, IOWriter)
Frame(writer::Writer) = Frame(writer.topology)

# These dicts stores associations between extensions and file types.
# The key is the default extension, the values are tuples (file_type, Reader|Writer).
TRAJECTORIES_READERS = Dict{String, (String, DataType)}()
TRAJECTORIES_WRITERS = Dict{String, (String, DataType)}()

function register_reader(;extension="", filetype="", reader=Any)
    extension == "" && error("Default extention can not be empty")
    reader <: FormatReader || error("reader should be a subtype of FormatReader")
    TRAJECTORIES_READERS[extension] = (filetype, reader)
    # TODO: add check on methods
end

function register_writer(;extension="", filetype="", writer=Any)
    extension == "" && error("Default extention can not be empty")
    writer <: FormatWriter || error("writer should be a subtype of FormatWriter")
    TRAJECTORIES_WRITERS[extension] = (filetype, writer)
    # TODO: add check on methods
end

# ============================================================================ #
#                 Iterator interface for trajectories IO
# ============================================================================ #

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

function read_next_frame!{T<:FormatReader}(t::Reader{T}, ::Frame)
   throw(NotImplementedError("Method read_next_frame! not implemented for "*
                             "$(typeof(t.reader)) trajectory type"))
end

function read_frame!{T<:FormatReader}(t::Reader{T}, ::Integer, ::Frame)
    throw(NotImplementedError("Method read_frame! not implemented for "*
                              "$(typeof(t.reader)) trajectory type"))
end

# ============================================================================ #
#                             Trajectory formats
# ============================================================================ #

function get_in_kwargs(kwargs, key::Symbol, default)
    value = default
    try
        KW = Dict(convert(Array{(Symbol,Any), 1}, kwargs))
        value = KW[key]
    end
    return value
end

include("XYZ/Reader.jl")
include("XYZ/Writer.jl")

include("NetCDF/Reader.jl")
include("NetCDF/Writer.jl")

@doc """
This function returns an object of type <TRAJ_TYPE><Reader|Writer>,
or raise an error if it is impossible to create such object.
The trajectory format is guessed from the extension.

Positional argument
-------------------

 - filename::String, the file path

Keyword arguments
-----------------

 - mode::String, "r" for read or "w" for write;
 - tologogy::String, path to a topology file, for reading;
 - All other keywords arguments are passed to the TrajectoryIO contructor.
""" ->
function opentraj(filename::String; mode="r", topology="", kwargs...)
    extension = split(strip(filename), ".")[end]
    if mode == "r"
        if haskey(TRAJECTORIES_READERS, extension)
            trajtype, reader = TRAJECTORIES_READERS[extension]
            info(".$extension extension, assuming $trajtype trajectory at input")
            FormatReader = reader(filename; kwargs...)
        else
            error("The '$extension' extension is not recognized. " *
                  "Please provide a trajectory type.")
        end
        natoms, _ = get_traj_infos(FormatReader)
        if topology != ""
            topo = Topology(topology)
        else
            info("You may want to use atomic names, providing a topology file")
            topo = dummy_topology(natoms)
        end
        return Reader(FormatReader, topo)
    elseif mode =="w"
        if haskey(TRAJECTORIES_WRITERS, extension)
            trajtype, writer = TRAJECTORIES_WRITERS[extension]
            info(".$extension extension, assuming $trajtype trajectory at output")
            FormatWriter = writer(filename; kwargs...)
        else
            error("The '$extension' extension is not recognized. " *
                  "Please provide a trajectory type.")
        end
        return Writer(FormatWriter)
    else
        error("Only read ('r') and write ('w') modes are supported")
    end
    return nothing
end

Reader(filename::String; kwargs...) = opentraj(filename; mode="r", kwargs...)
Writer(filename::String; kwargs...) = opentraj(filename; mode="w", kwargs...)

close(traj::Reader) = close(traj.reader.file)
isopen(traj::Reader)= isopen(traj.reader.file)

close(traj::Writer) = close(traj.writer.file)
isopen(traj::Writer)= isopen(traj.writer.file)
