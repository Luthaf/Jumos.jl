#===============================================================================
                    Open and read a frame from the trajectories
===============================================================================#

const TEST_DIR = dirname(Base.source_path())

# NetCDF
traj = Reader("$TEST_DIR/trjs/water.nc", topology="$TEST_DIR/trjs/water.lmp")
    frame = Frame(traj)
    read_next_frame!(traj, frame)
    @test length(frame.positions) == traj.natoms
close(traj)

# XYZ
traj = Reader("$TEST_DIR/trjs/water.xyz", box=[15.0, 15.0, 15.0])
    frame = Frame(traj)
    read_frame!(traj, 500, frame)
    @test length(frame.positions) == traj.natoms
close(traj)