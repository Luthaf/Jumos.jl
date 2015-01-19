energy = EnergyCompute()
T = TemperatureCompute()

facts("Simulation internals") do
    context("Get forces & total force is null") do
        sim = testing_simulation()

        Simulations.get_forces!(sim)
        tot_force = sim.forces[1] .+ sim.forces[2] .+ sim.forces[3] .+ sim.forces[4]

        @fact tot_force => roughly([0.0, 0.0, 0.0])
    end
end

facts("Simulation UI") do
    context("Set velocities") do
        sim = testing_simulation()
        set_frame(sim, dummy_frame(300))

        context("Bolztmann distribution") do

            create_velocities(sim, 300)
            @fact T(sim) => greater_than(250)
            @fact T(sim) => less_than(350)
        end

        context("Constant distribution") do
            create_velocities(sim, 300, initializer="random")
            @fact T(sim) => greater_than(250)
            @fact T(sim) => less_than(350)
        end
    end

    context("Trajectory output") do
        sim = testing_simulation()
        tmpname = tempname() * ".xyz"
        out_trajectory = TrajectoryOutput(tmpname, 1)
        add_output(sim, out_trajectory)

        run!(sim, 500)

        rm(tmpname)
    end
end

facts("Simulation physical consistency") do
    context("Constant energy for VelocityVerlet integrator") do
        sim = testing_simulation(50)
        Ekin, Epot, Etot_initial = energy(sim)

        @fact Ekin + Epot => Etot_initial
        run!(sim, 500)

        _, __, Etot_final = energy(sim)
        # The big tolerance is here because the simulation only have 50 atoms.
        @fact abs(Etot_final - Etot_initial) => less_than(1.0)
    end

    context("Constant energy for Verlet integrator") do
        sim = testing_simulation(50)
        sim.integrator = Verlet(1.0)
        Ekin, Epot, Etot_initial = energy(sim)

        @fact Ekin + Epot => Etot_initial
        run!(sim, 500)

        _, __, Etot_final = energy(sim)
        # The big tolerance is here because the simulation only have 50 atoms.
        @fact abs(Etot_final - Etot_initial) => less_than(2.0)
    end
end
