# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#               Implementation of the NetCDF trajectories Reader
#
# NetCDF-based format, with .nc extention. The AMBER convention is used.
# See http://www.unidata.ucar.edu/software/netcdf/ for NetCDF description
# See http://ambermd.org/netcdf/nctraj.xhtml for the convention.
# ============================================================================ #

import NetCDF

type NCReader <: FormatReader
    file::NetCDF.NcFile
end

register_reader(extension="nc", filetype="Amber NetCDF", reader=NCReader)

function NCReader(filename::String; kwargs...)
    file = NetCDF.open(filename)
    is_AMBER = false
    try
        is_AMBER = contains(file.gatts["Conventions"], "AMBER")
    end
    if !is_AMBER
        error("This software can only read AMBER convention for NetCDF files.")
    end
    return NCReader(file)
end

function get_traj_infos(r::NCReader)
    natoms = Int(r.file.dim["atom"].dimlen)
    nsteps = Int(r.file.dim["frame"].dimlen)
    return natoms, nsteps
end

function read_next_frame!(traj::Reader{NCReader}, universe::Universe)
    traj.current_step += 1
    read_frame!(traj, traj.current_step, universe)
end

function read_frame!(traj::Reader{NCReader}, step::Integer, universe::Universe)
    if step > traj.nsteps || step < 1
        max = traj.nsteps
        error("Can not read step $step. Maximum step: $max")
    end
    universe.data[:step] = step
    universe.frame.positions = NetCDF.readvar(traj.reader.file,
                                              "coordinates",
                                              start=[1,1,step],
                                              count=[-1,-1,1])[:,:,1]

    if false # Todo: add a velocity parameter
        universe.frame.velocities = NetCDF.readvar(traj.reader.file,
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
    universe.cell = UnitCell(length, angles)
    if step >= traj.nsteps
        return false
    else
        return true
    end
end

Base.close(traj::Reader{NCReader}) = NetCDF.ncclose(traj.reader.file.name)
