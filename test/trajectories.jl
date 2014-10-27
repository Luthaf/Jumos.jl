#===============================================================================
            Test the Trajectory IO : open, read, write and close

                This is only a minimalistic test, which can
                could be inproved.
===============================================================================#
const TEST_DIR = dirname(Base.source_path())

# NetCDF read
traj = Reader("$TEST_DIR/trjs/water.nc", topology="$TEST_DIR/trjs/water.lmp")
    frame = Frame(traj)
    read_next_frame!(traj, frame)
    @test length(frame.positions) == traj.natoms
close(traj)

# XYZ read and write
tmp = tempname()
outtraj = Writer("$tmp.xyz")
traj = Reader("$TEST_DIR/trjs/water.xyz", box=[15.0, 15.0, 15.0])
    frame = Frame(traj)
    read_frame!(traj, 500, frame)
    @test length(frame.positions) == traj.natoms

    writetraj(outtraj, frame)

    frames = Frame[]
    for i=1:10
        read_frame!(traj, i, frame)
        push!(frames, frame)
    end
    writetraj(outtraj, frames)
close(traj)
close(outtraj)
rm("$tmp.xyz")
