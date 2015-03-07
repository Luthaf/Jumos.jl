
facts("Thermostats") do
    context("Berendsen thermostat") do
        universe = testing_universe_from_size(50)
        sim = Simulation(:MD)
        push!(sim, BerendsenThermostat(300, 10))
        create_velocities!(universe, 200)

        propagate!(sim, universe, 1000)
        T_end = T(universe)
        @fact T_end => roughly(300, atol=50)
    end

    context("Velocity rescale thermostat") do
        universe = testing_universe_from_size(50)
        sim = Simulation(:MD)
        push!(sim, VelocityRescaleThermostat(300, 10))
        create_velocities!(universe, 200)

        propagate!(sim, universe, 1000)
        T_end = T(universe)
        @fact T_end => roughly(300, atol=20)
    end
end
