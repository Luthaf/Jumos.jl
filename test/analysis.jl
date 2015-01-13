facts("Analysis module") do
    TRAJ_DIR = joinpath(dirname(@__FILE__), "trjs")
    traj = Reader("$TRAJ_DIR/water.nc", topology="$TRAJ_DIR/water.lmp")
    tmp = tempname()

    context("Density profile") do
        rho = DensityProfile("O", 3)
        for frame in eachframe(traj, start=50)
            update!(rho, frame)
        end
        normalize!(rho)
        write(rho, "dummy", outname=tmp)
        @pending "add some more tests here" => :TODO
    end

    context("Radial distrubution function") do
        rdf = RDF("O")
        for frame in eachframe(traj, start=50)
            update!(rdf, frame)
        end
        normalize!(rdf)
        write(rdf, "dummy", outname=tmp)
        @pending "add some more tests here" => :TODO
    end

    rm(tmp)
    close(traj)
end
