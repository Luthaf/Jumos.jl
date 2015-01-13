facts("Trajectory IO") do
    TRAJ_DIR = joinpath(dirname(@__FILE__), "trjs")
    
    context("NetCDF") do
        traj = Reader("$TRAJ_DIR/water.nc", topology="$TRAJ_DIR/water.lmp")
        frame = Frame(traj)
        read_next_frame!(traj, frame)

        @fact length(frame.positions) => traj.natoms

        @fact frame.topology[1].name => "O"
        @fact frame.topology[1].symbol => "O"
        @fact frame.topology[2].name => "H"
        @fact frame.topology[2].symbol => "H"
        @fact frame.topology[1].mass => 15.999
        @fact size(frame.topology.atom_types, 1) => 2

        close(traj)
    end

    context("XYZ") do
        tmp = tempname()
        outtraj = Writer("$tmp.xyz")
        traj = Reader("$TRAJ_DIR/water.xyz",
                      topology="$TRAJ_DIR/water.xyz", cell=[15.0, 15.0, 15.0])

        context("Reading") do
            frame = Frame(traj)
            read_frame!(traj, 50, frame)
            @fact length(frame.positions) => traj.natoms

            @fact frame.topology[4].name => "O"
            @fact frame.topology[4].symbol => "O"
            @fact frame.topology[4].mass => ATOMIC_MASSES["O"].val
        end

        context("Writing") do
            frame = Frame(traj)
            read_frame!(traj, 50, frame)
            write(outtraj, frame)

            frames = Frame[]
            for i=1:10
                read_frame!(traj, i, frame)
                push!(frames, frame)
            end
            write(outtraj, frames)

            @pending "check the first and last lines of the writen traj" => :TODO
        end

        close(traj)
        close(outtraj)
        rm("$tmp.xyz")
    end

end
