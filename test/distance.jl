function testing_frame(cell)
    top = dummy_topology(4)
    frame = Frame(top)
    frame.positions[1] = [2, 2, 4]
    frame.positions[2] = [2, 2, 2]
    frame.positions[3] = [-45, 2, 300.56]
    frame.positions[4] = [29, 22, 45]
    frame.cell = cell
    return frame
end

# Cell for later usage
orthorombic = UnitCell(10.0)
infitite = UnitCell(InfiniteCell)
triclinic1 = UnitCell(10.0, 10.0, 10.0, 2*pi/5, pi/2, 2*pi/3)
triclinic2 = UnitCell(10.0, TriclinicCell)

facts("Distances computations") do

    context("UnitCell constructor") do
        @fact UnitCell(13.) => UnitCell(13., 13., 13.)
        @fact UnitCell(13.) => UnitCell(13., 13., 13., pi/2, pi/2, pi/2)
    end

    context("Basic distance computations") do
        frame = testing_frame(UnitCell(10.))
        @fact distance(frame, 1, 2) => 2.0
        @pending "distance(ref, conf, i, j) method" => :TODO
        @pending "distance(ref, conf, i) method" => :TODO
    end

    context("Equivalent orthorombic and triclinic") do
        frame = testing_frame(orthorombic)
        frame2 = testing_frame(triclinic2)
        @fact distance_array(frame2) => distance_array(frame)
    end

    context("Distance symetry") do
        for cell in [orthorombic, infitite, triclinic1, triclinic2]
            frame = testing_frame(cell)
            for i=1:4, j=1:4
                @fact distance(frame, i, j) => distance(frame, j, i)
            end
        end
    end
end

facts("Minimal images") do
    context("Orthorombic cell") do
        frame = testing_frame(orthorombic)
        @fact minimal_image(frame.positions[1], orthorombic) => frame.positions[1]
        @fact minimal_image(frame.positions[3], orthorombic) => roughly([-5.0, 2.0, 0.56])
        @fact minimal_image(frame.positions[4], orthorombic) => roughly([-1.0, 2.0, 5.0])

        # Mutating version
        minimal_image!(frame.positions[4], orthorombic)
        @fact [frame.positions[4]...] => roughly([-1.0, 2.0, 5.0])
    end

    context("Triclinic cell") do
        frame = testing_frame(orthorombic)

        @fact minimal_image(frame.positions[1], triclinic2) => [frame.positions[1]...]
        @pending minimal_image(frame.positions[1], triclinic1) => ["compute the real values"]
    end

    context("Infinite cell") do
        frame = testing_frame(infitite)
        @fact minimal_image(frame.positions[1], infitite) => [frame.positions[1]...]
        @fact minimal_image(frame.positions[3], infitite) => [frame.positions[3]...]
        @fact minimal_image(frame.positions[4], infitite) => [frame.positions[4]...]
    end
end

facts("Volume computation") do
    @fact volume(orthorombic) => 10.^3
    @fact volume(triclinic2) => volume(orthorombic)
    @fact volume(infitite) => 0.
    V = 10.0^3 * sqrt(1 - cos(2*pi/5)^2 - cos(pi/2)^2 - cos(2*pi/3)^2
                        + 2*cos(2*pi/5)^2*cos(pi/2)^2*cos(2*pi/3)^2  )
    @fact volume(triclinic1) => V
end
