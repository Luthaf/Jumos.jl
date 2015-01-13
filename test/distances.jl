top = dummy_topology(4)

frame = Frame(top)

orthorombic = UnitCell(10.)
infitite = UnitCell(InfiniteCell)
triclinic1 = UnitCell(10, 10, 10, 80, 90, 120)
triclinic2 = UnitCell(10., 10., 10., TriclinicCell)

@test UnitCell(13.) == UnitCell(13., 13., 13.)
@test UnitCell(13.) == UnitCell(13., 13., 13., pi/2, pi/2, pi/2)

frame.positions[1] = [2, 2, 4]
frame.positions[2] = [2, 2, 2]
frame.positions[3] = [-45, 2, 300.56]
frame.positions[4] = [29, 22, 45]

frame.cell = orthorombic

frame2 = Frame(top)
frame2.positions = copy(frame.positions)
frame2.cell = triclinic2

for i=1:4, j=1:4
    # This fail for now, let's fix it later
    # @test distance(frame, i, j) == distance(frame2, i, j)
end

@test distance(frame, 1, 2) == 2.0

for cell in [orthorombic, infitite, triclinic1, triclinic2]
    frame.cell = cell
    for i=1:4, j=1:4
        @test distance(frame, i, j) == distance(frame, j, i)
    end
end

# TODO: test the distance(ref, conf, i, j) and distance(ref, conf, i) methods

# frame.positions[1] is in the cell, and should stay inside
@test minimal_image(frame.positions[1], orthorombic) == frame.positions[1]
@test minimal_image(frame.positions[1], infitite) == [frame.positions[1]...]
@test minimal_image(frame.positions[1], triclinic1) == [frame.positions[1]...]
# TODO: fix this and L26.
#@test minimal_image(frame.positions[1], triclinic2) == [frame.positions[1]...]

@test isapprox(minimal_image(frame.positions[3], orthorombic), [5.0, 2.0, 0.56])
@test isapprox(minimal_image(frame.positions[4], orthorombic), [-1, 2.0, -5.0])
@test minimal_image(frame.positions[3], infitite) == [frame.positions[3]...]
@test minimal_image(frame.positions[4], infitite) == [frame.positions[4]...]

# check mutating version
minimal_image!(frame.positions[4], orthorombic)
@test isapprox([frame.positions[4]...], [-1, 2.0, -5.0])

@test volume(orthorombic) == 10.^3
@test volume(orthorombic) == volume(triclinic2)
@test volume(infitite) == 0.
# TODO: compute this by hand
# @test volume(triclinic1) ==
