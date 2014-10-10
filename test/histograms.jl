#===============================================================================
                        Test the histograms functions
===============================================================================#

const TEST_DIR = dirname(Base.source_path())

traj = Reader("$TEST_DIR/trjs/water.nc", topology="$TEST_DIR/trjs/water.lmp")

    tmp = tempname()

    info("Testing DensityProfile")
    tic()
    rho = DensityProfile("O", 3)
    for frame in eachframe(traj, start=950)
        update!(rho, frame)
    end
    normalize!(rho)
    write(rho, "dummy", outname=tmp)
    toc()

    info("Testing RDF")
    tic()
    rdf = RDF("O")
    for frame in eachframe(traj, start=950)
        update!(rdf, frame)
    end
    normalize!(rdf)
    write(rdf, "dummy", outname=tmp)
    toc()

    rm(tmp)

close(traj)