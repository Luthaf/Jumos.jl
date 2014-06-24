using MolecularAnalysis
using Base.Test

#===============================================================================
                    Open and read a frame from the trajectories
===============================================================================#

const TEST_DIR = dirname(Base.source_path())

# NetCDF
traj = opentraj("$TEST_DIR/trjs/water.nc", topology="$TEST_DIR/trjs/water.lmp")

frame = Frame(traj)
read_frame!(traj, 500, frame)

close(traj)

# XYZ
traj = opentraj("$TEST_DIR/trjs/water.xyz", box=[15.0, 15.0, 15.0])

frame = Frame(traj)
read_frame!(traj, 500, frame)

close(traj)
