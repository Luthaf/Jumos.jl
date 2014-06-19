#===============================================================================
         Implementation of the NetCDF trajectories Reader

    NetCDF-based format, with .nc extention. The AMBER convention is used.
        See http://www.unidata.ucar.edu/software/netcdf/ for NetCDF description
        See http://ambermd.org/netcdf/nctraj.xhtml for the convention.
===============================================================================#
using NetCDF

type NCReader <: BaseReader
    nsteps::Integer
    current_step::Integer
    file::NcFile
end

function NCReader(filename::String, topology::String="")
    file = NetCDF.open(filename)
    is_AMBER = false
    try
        is_AMBER = contains(file.gatts["Conventions"], "AMBER")
    catch
        is_AMBER = false
    end
    if !is_AMBER
        error("This software can only read AMBER convention for NetCDF files.")
    end
    natoms = file.dim["atom"].dimlen
    nsteps = file.dim["frame"].dimlen
    top = String[]
    if topology==""
        for i=1:natoms
            push!(top, string(i))
        end
    else
        top = read_topology(topology)
    end
    return NCReader(natoms, nsteps, 0, file, top)
end


# Read the next step of a trajectory.
# Return True if there is still some step(s) to read, false otherwhile
function read_next_frame!(traj::NCReader, frame::Frame)
    traj.current_step += 1
    read_frame!(traj, traj.current_step, frame)
end

# Read a given step of a trajectory.
# Return True if there is still some step(s) to read, false otherwhile
function read_frame!(traj::NCReader, step::Integer, frame::Frame; vel=false)
    if step > traj.nsteps || step < 1
        max = traj.nsteps
        error("Can not read step $step. Maximum step: $max")
    end
    frame.step = step
    frame.natoms = traj.natoms

    frame.positions = NetCDF.readvar(traj.file,
                               "coordinates",
                               start=[1,1,step],
                               count=[-1,-1,1])[:,:,1]

    if vel
        frame.velocities = NetCDF.readvar(traj.file,
                                   "velocities",
                                   start=[1,1,step],
                                   count=[-1,-1,1])[:,:,1]
    end

    types = NetCDF.readvar(traj.file, "atom_types")
    frame.labels = String[] # Clearing the labels
    for i=1:traj.natoms
        push!(frame.labels, traj.topology[types[i]])
    end

    frame.box = NetCDF.readvar(traj.file,
                               "cell_lengths",
                               start=[1, step],
                               count=[-1,1])[:,1]
    if step >= traj.nsteps
        return false
    else
        return true
    end
end

# This function read a '.lmp' file to find about atomic names associated to
# the atomic types.
function read_topology(filename::String)
    topology = String[]
    if split(filename, '.')[end] != "lmp"
        error("Only .lmp topology files are supported")
    end
    open(filename) do f
        line = readline(f)
        while !contains(line, "# Bond Coeffs", )
            if contains(line, "#")
                try
                    i = int(split(line)[2])
                    name = split(line)[3]
                    push!(topology, name)
                catch
                    # do nothing in case of error, just wait for the next
                    # valid conversion. This may hardly fail.
                end
            end
            line = readline(f)
        end
    end
    return topology
end
