energy = EnergyCompute()
T = TemperatureCompute()

facts("Simulation UI") do
    context("Set velocities") do
        universe = testing_universe_from_size(300)

        context("Bolztmann distribution") do
            create_velocities!(universe, 300)
            @fact T(universe) => greater_than(250)
            @fact T(universe) => less_than(350)
        end

        context("Constant distribution") do
            create_velocities!(universe, 300, initializer="random")
            @fact T(universe) => greater_than(250)
            @fact T(universe) => less_than(350)
        end
    end

    context("Trajectory output") do
        universe = testing_universe_from_size(10)
        sim = Simulation(:MD)
        tmpname = tempname() * ".xyz"
        out_trajectory = TrajectoryOutput(tmpname, 1)
        push!(sim, out_trajectory)

        propagate!(sim, universe, 500)

        rm(tmpname)
    end
end

facts("Simulation physical consistency") do
    context("Constant energy for VelocityVerlet integrator") do
        universe = testing_universe_from_size(50)
        sim = Simulation(:MD)
        Ekin, Epot, Etot_initial = energy(universe)

        @fact Ekin + Epot => Etot_initial
        propagate!(sim, universe, 500)

        _, __, Etot_final = energy(universe)
        # The big tolerance is here because the simulation only have 50 atoms.
        @fact abs(Etot_final - Etot_initial) => less_than(1.0)
    end

    context("Constant energy for Verlet integrator") do
        universe = testing_universe_from_size(50)
        sim = Simulation(:MD)
        set_integrator!(sim, Verlet(1.0))
        Ekin, Epot, Etot_initial = energy(universe)

        @fact Ekin + Epot => Etot_initial
        propagate!(sim, universe, 500)

        _, __, Etot_final = energy(universe)
        # The big tolerance is here because the simulation only have 50 atoms.
        @fact abs(Etot_final - Etot_initial) => less_than(5.0)
    end
end
