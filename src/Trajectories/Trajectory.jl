# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#            Trajectories reading and writing through iterators
# ============================================================================ #

export Reader, Writer
export read_next_frame!, read_frame!, opentraj
export register_reader, register_writer

type TrajectoryIOError <: Exception
    message::String
end

function Base.show(io::IO, e::TrajectoryIOError)
    show(io, e.message)
end

abstract FormatReader
type Reader{T<:FormatReader}
    natoms::Int
    nsteps::Int
    current_step::Int
    reader::T
end

function Reader(r::FormatReader)
    natoms, nsteps = get_traj_infos(r)
    return Reader(natoms, nsteps, 0, r)
end

abstract FormatWriter
type Writer{T<:FormatWriter}
    current_step::Int
    writer::T
end

Writer(IOWriter::FormatWriter) = Writer(0, IOWriter)

# These dicts stores associations between extensions and file types.
# The key is the default extension, the values are tuples (file_type, Reader|Writer).
TRAJECTORIES_READERS = Dict{String, Tuple{String, DataType}}()
TRAJECTORIES_WRITERS = Dict{String, Tuple{String, DataType}}()

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

function read_next_frame!{T<:FormatReader}(t::Reader{T}, ::Universe)
   throw(NotImplementedError("Method read_next_frame! not implemented for "*
                             "$(typeof(t.reader)) trajectory type"))
end

function read_frame!{T<:FormatReader}(t::Reader{T}, ::Integer, ::Universe)
    throw(NotImplementedError("Method read_frame! not implemented for "*
                              "$(typeof(t.reader)) trajectory type"))
end

# ============================================================================ #
#                             Trajectory formats
# ============================================================================ #

function get_in_kwargs(kwargs, key::Symbol, default)
    value = default
    try
        KW = Dict(convert(Array{Tuple{Symbol, Any}, 1}, kwargs))
        value = KW[key]
    end
    return value
end

include("XYZ/Reader.jl")
include("XYZ/Writer.jl")

"""
`opentraj(filename; mode="r", kwargs...)`

This function returns an object of type <TRAJ_TYPE><Reader|Writer>, or raise an
error if it is impossible to create such object. The trajectory format is
guessed from the extension.

# Positional argument

- filename::String, the file path

# Keyword arguments

- `mode::String`, "r" for read or "w" for write;
- `tologogy::String`, path to a topology file, for reading;
- Any other keywords arguments are passed to the TrajectoryIO contructor.
"""
function opentraj(filename::String; mode="r", topology="", kwargs...)
    extension = split(strip(filename), ".")[end]
    if mode == "r"
        if haskey(TRAJECTORIES_READERS, extension)
            trajtype, reader = TRAJECTORIES_READERS[extension]
            info(".$extension extension, assuming $trajtype trajectory at input")
            FormatReader = reader(filename; kwargs...)
        else
            error("The '$extension' extension is not recognized.")
        end
        return Reader(FormatReader)
    elseif mode =="w"
        if haskey(TRAJECTORIES_WRITERS, extension)
            trajtype, writer = TRAJECTORIES_WRITERS[extension]
            info(".$extension extension, assuming $trajtype trajectory at output")
            FormatWriter = writer(filename; kwargs...)
        else
            error("The '$extension' extension is not recognized.")
        end
        return Writer(FormatWriter)
    else
        error("Only read ('r') and write ('w') modes are supported")
    end
    return nothing
end

Reader(filename::String; kwargs...) = opentraj(filename; mode="r", kwargs...)
Writer(filename::String; kwargs...) = opentraj(filename; mode="w", kwargs...)

Base.close(traj::Reader) = close(traj.reader.file)
Base.isopen(traj::Reader)= isopen(traj.reader.file)

Base.close(traj::Writer) = close(traj.writer.file)
Base.isopen(traj::Writer)= isopen(traj.writer.file)

export positions_from_file!

function positions_from_file!(univ::Universe, filename::AbstractString)
    reader = opentraj(filename)
    read_next_frame!(reader, univ)
    close(reader)
end

# Todo:
# function velocities_from_file!
