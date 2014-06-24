#===============================================================================
             Trajectories reading and writing through iterators
===============================================================================#

# Trajectory type
abstract MDTrajectory
abstract BaseReader <: MDTrajectory
abstract BaseWriter <: MDTrajectory


# Simulation box type
typealias Box Array{Real,1}

box(Lx::Real, Ly::Real, Lz::Real) = Real[Lx, Ly, Lz]
box(L::Real) = box(L, L, L)
box() = box(0)


# The Frame type holds a frame, i.e. one step of a simulation.
type Frame
    step::Integer
    positions::Array{Real,2}
    velocities::Array{Real,2}
    box::Box
end

Frame(natoms::Integer) = Frame(-1,
                               Array(Float64, 3, natoms),
                               Array(Float64, 3, natoms),
                               Box()
                              )
Frame() = Frame(0)

#==============================================================================#
#==============================================================================#

include("Trajectories/XYZ/Reader.jl")
include("Trajectories/XYZ/Writer.jl")

include("Trajectories/NetCDF/Reader.jl")
include("Trajectories/NetCDF/Writer.jl")

# Dispatcher opening a trajectory. Will return an object
# of type <TRAJ_TYPE><Reader|Writer>. The trajectory format is
# assumed from the extension.
function opentraj(filename, mode="r"; kwargs...)
    extension = split(strip(filename), ".")[end]
    kwargs = Dict(convert(Array{(Symbol,Any), 1}, kwargs))
    if mode == "r"
        if extension == "xyz"
            info(".xyz extension, assuming XYZ trajectory")
            if !(haskey(kwargs, :box) & isa(kwargs[:box], Box))
                error("You should give a box size for opening XYZ trajectories")
            end
            return XYZReader(filename, kwargs[:box])
        elseif extension == "nc"
            info(".nc extension, assuming NetCDF trajectory")
            if !(haskey(kwargs, :topology) & isa(kwargs[:topology], String))
                info("You may want to use atomic names, providing a topology file")
            end
            topology = get(kwargs, :topology, "")
            return NCReader(filename, topology)
        else
            error("The '$extension' extension is not recognized")
        end
    else
        error("Only read mode is supported")
    end
end
