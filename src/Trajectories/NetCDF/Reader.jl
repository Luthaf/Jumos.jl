#===============================================================================
         Implementation of the NetCDF trajectories Reader

    NetCDF-based format, with .nc extention. The AMBER convention is used.
        See http://www.unidata.ucar.edu/software/netcdf/ for NetCDF description
        See http://ambermd.org/netcdf/nctraj.xhtml for the convention.
===============================================================================#
using NetCDF

type NCReader <: AbstractReaderIO
    file::NcFile
end

function NCReader(filename::String)
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
    return NCReader(file)
end

function get_traj_infos(r::NCReader)
    # int() convert to machine integers
    natoms = int(r.file.dim["atom"].dimlen)
    nsteps = int(r.file.dim["frame"].dimlen)
    return natoms, nsteps
end

function read_next_frame!(traj::Reader{NCReader}, frame::Frame)
    traj.current_step += 1
    read_frame!(traj, traj.current_step, frame)
end

function read_frame!(traj::Reader{NCReader}, step::Integer, frame::Frame)
    if step > traj.nsteps || step < 1
        max = traj.nsteps
        error("Can not read step $step. Maximum step: $max")
    end
    frame.step = step
    frame.positions = NetCDF.readvar(traj.reader.file,
                               "coordinates",
                               start=[1,1,step],
                               count=[-1,-1,1])[:,:,1]

    if false
        frame.velocities = NetCDF.readvar(traj.reader.file,
                                   "velocities",
                                   start=[1,1,step],
                                   count=[-1,-1,1])[:,:,1]
    end

    length = NetCDF.readvar(traj.reader.file,
                               "cell_lengths",
                               start=[1, step],
                               count=[-1,1])[:,1]
    angles = NetCDF.readvar(traj.reader.file,
                               "cell_angles",
                               start=[1, step],
                               count=[-1,1])[:,1]
    frame.box = Box(length, angles)
    if step >= traj.nsteps
        return false
    else
        return true
    end
end

close(traj::Reader{NCReader}) = ncclose(traj.reader.file.name)
