#===============================================================================
                        Test the histograms functions
===============================================================================#

TEST_DIR = dirname(Base.source_path())

traj = Reader("$TEST_DIR/trjs/water.nc", topology="$TEST_DIR/trjs/water.lmp")

    tmp = tempname()

    info("Testing DensityProfile")
    @time begin
        rho = DensityProfile("O", 3)
        for frame in eachframe(traj, start=50)
            update!(rho, frame)
        end
        normalize!(rho)
        write(rho, "dummy", outname=tmp)
    end

    info("Testing RDF")
    @time begin
        rdf = RDF("O")
        for frame in eachframe(traj, start=50)
            update!(rdf, frame)
        end
        normalize!(rdf)
        write(rdf, "dummy", outname=tmp)
    end

    rm(tmp)

close(traj)
