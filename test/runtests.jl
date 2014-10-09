tic()
using MolecularAnalysis
println("Load time: $(toq())")
using Base.Test

#===============================================================================
                        Test the vectors
===============================================================================#
a = vect3d(2,8,6.)
b = vect3d(4)

@test a*2 == vect3d(4.,16.,12.)
@test a*2 == 2*a
@test a/2 == vect3d(1.,4.,3.)

@test a + b == vect3d(6.,12.,10.)
@test a - b == vect3d(-2.,4.,2.)

@test a*b == 64.0
@test a^a == vect3d(0.0)
@test (a^b)*a == 0.0
@test (b^a)*b == 0.0

#@test norm(a) == sqrt(104.0)

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



#===============================================================================
                        Test the histograms functions
===============================================================================#

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
