#===============================================================================
         Implementation of the NetCDF trajectories Reader

    NetCDF-based format, with .nc extention. The AMBER convention is used.
        See http://www.unidata.ucar.edu/software/netcdf/ for NetCDF description
        See http://ambermd.org/netcdf/nctraj.xhtml for the convention.
===============================================================================#
using NetCDF

type NCReader <: BaseReader
    natoms::Integer
    nsteps::Integer
    current_step::Integer
    file::NcFile
    topology::Topology
end

function NCReader(filename::String, topology_file::String="")
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

    if topology_file == ""
        topology = Topology(natoms)
        for i=1:natoms
            topology.atoms[i] = Atom(string(i))
        end
    else
        topology = read_topology(topology_file)
    end
    return NCReader(natoms, nsteps, 0, file, topology)
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


import Base.close
Base.close(traj::NCReader) = ncclose(traj.file.name)
