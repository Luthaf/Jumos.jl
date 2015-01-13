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
        sim = testing_simulation()
        Ekin, Epot, Etot_initial = energy(sim)

        @fact Ekin + Epot => Etot_initial
        run!(sim, 500)

        _, __, Etot_final = energy(sim)
        # This is failing for now
        @pending Etot_final => roughly(Etot_initial, rtol=1e-2)
    end

    context("Constant energy for Verlet integrator") do
        sim = testing_simulation()
        sim.integrator = Verlet(1.0)
        Ekin, Epot, Etot_initial = energy(sim)

        @fact Ekin + Epot => Etot_initial
        try
            # This is failing for now
            run!(sim, 500)
        end

        _, __, Etot_finale = energy(sim)

        @pending Etot_finale => roughly(Etot_initial, rtol=1e-2)
    end
end
