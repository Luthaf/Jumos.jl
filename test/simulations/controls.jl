
facts("Thermostats") do
    context("Berendsen thermostat") do
        sim = testing_simulation()
        set_frame(sim, dummy_frame(50))

        add_control(sim, BerendsenThermostat(300, 10))
        create_velocities(sim, 200)

        run!(sim, 1000)
        T_end = T(sim)
        @fact T_end => roughly(300, atol=20)
    end

    context("Velocity rescale thermostat") do
        sim = testing_simulation()
        set_frame(sim, dummy_frame(50))

        add_control(sim, VelocityRescaleThermostat(300, 10))
        create_velocities(sim, 200)

        run!(sim, 1000)
        T_end = T(sim)
        @fact T_end => roughly(300, atol=20)
    end
end
