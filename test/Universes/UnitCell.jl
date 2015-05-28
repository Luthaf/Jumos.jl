function testing_universe_from_cell(cell)
    top = dummy_topology(4)
    frame = Frame(4)
    frame.positions[1] = [2, 2, 4]
    frame.positions[2] = [2, 2, 2]
    frame.positions[3] = [-45, 2, 300.56]
    frame.positions[4] = [29, 22, 45]
    universe = Universe(cell, top)
    universe.frame = frame
    return universe
end

# Cell for later usage
const orthorombic = UnitCell(10.0)
const infitite = UnitCell(InfiniteCell)
const triclinic1 = UnitCell(10.0, 10.0, 10.0, 2*pi/5, pi/2, 2*pi/3)
const triclinic2 = UnitCell(10.0, TriclinicCell)

facts("UnitCell type") do

    context("Constructors") do
        @fact UnitCell(13.) => UnitCell(13., 13., 13.)
        @fact UnitCell(13.) => UnitCell(13., 13., 13., pi/2, pi/2, pi/2)

        @fact isa(orthorombic, UnitCell{OrthorombicCell}) => true
        @fact isa(infitite, UnitCell{InfiniteCell}) => true
        @fact isa(triclinic1, UnitCell{TriclinicCell}) => true

        @fact isa(UnitCell(10.0, OrthorombicCell), UnitCell{OrthorombicCell}) => true
        @fact isa(UnitCell(10.0, TriclinicCell), UnitCell{TriclinicCell}) => true
        @fact isa(UnitCell(10.0, InfiniteCell), UnitCell{InfiniteCell}) => true
    end

    context("Basic distance computations") do
        universe = testing_universe_from_cell(UnitCell(10.))
        @fact distance(universe, 1, 2) => 2.0
    end

    context("Equivalent orthorombic and triclinic cells") do
        universe = testing_universe_from_cell(orthorombic)
        universe2 = testing_universe_from_cell(triclinic2)
        @fact distance_array(universe) => distance_array(universe2)
    end

    context("Distances symetry") do
        for cell in [orthorombic, infitite, triclinic1, triclinic2]
            universe = testing_universe_from_cell(cell)
            for i=1:4, j=1:4
                @fact distance(universe, i, j) => distance(universe, j, i)
            end
        end
    end
end

facts("Minimal images") do
    context("Orthorombic cell") do
        universe = testing_universe_from_cell(orthorombic)
        @fact minimal_image(universe.frame.positions[1], orthorombic) => universe.frame.positions[1]
        @fact minimal_image(universe.frame.positions[3], orthorombic) => roughly([-5.0, 2.0, 0.56])
        @fact minimal_image(universe.frame.positions[4], orthorombic) => roughly([-1.0, 2.0, 5.0])

        # Mutating version
        minimal_image!(universe.frame.positions[4], orthorombic)
        @fact [universe.frame.positions[4]...] => roughly([-1.0, 2.0, 5.0])
    end

    context("Triclinic cell") do
        universe = testing_universe_from_cell(orthorombic)

        @fact minimal_image(universe.frame.positions[1], triclinic2) => [universe.frame.positions[1]...]
        @pending minimal_image(universe.frame.positions[1], triclinic1) => ["compute the real values"]
    end

    context("Infinite cell") do
        universe = testing_universe_from_cell(infitite)
        @fact minimal_image(universe.frame.positions[1], infitite) => [universe.frame.positions[1]...]
        @fact minimal_image(universe.frame.positions[3], infitite) => [universe.frame.positions[3]...]
        @fact minimal_image(universe.frame.positions[4], infitite) => [universe.frame.positions[4]...]
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
