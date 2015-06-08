facts("Trajectory IO") do
    TRAJ_DIR = joinpath(dirname(@__FILE__), "trjs")

    context("XYZ") do
        tmp = tempname()
        outtraj = Writer("$tmp.xyz")
        traj = Reader("$TRAJ_DIR/water.xyz")
        topology = Topology("$TRAJ_DIR/water.xyz")
        uni = Universe(UnitCell(), topology)

        context("Reading") do
            read_frame!(traj, 50, uni)
            @fact length(uni.frame.positions) => traj.natoms

            @fact uni.topology[4].label => :O
            @fact uni.topology[4].mass => ATOMIC_MASSES[:O]
        end

        context("Writing") do
            read_frame!(traj, 50, uni)
            write(outtraj, uni)
            @pending "check the first and last lines of the writen traj" => :TODO
        end

        close(traj)
        close(outtraj)
        rm("$tmp.xyz")
    end

end
