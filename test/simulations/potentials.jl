# Testing potentials

facts("Basic Potentials usage") do
    context("Harmonic potential") do
        harmonic = Harmonic(30, 2.0, -0.5)

        @fact harmonic(2.0) => -0.5
        @fact harmonic(4.0) => 59.5
        @fact force(harmonic, 2.0) => 0.0
        @fact force(harmonic, 3.0) => -30.0
    end

    context("Lennard-Jones potential") do
        lj = LennardJones(0.8, 2.0)

        @fact lj(2.0) => 0.0
        @fact lj(2.5) => -0.6189584744448002
        @fact force(lj, 2^(1./6.)*2.0) => roughly(0.0, atol=1e-15)
        @fact force(lj, 2.5) => roughly(-0.95773475733504, atol=1e-15)
    end

    context("User defined potential") do
        f(x) = 3*(x-3.5)^4
        g(x) = 12*(x-3.5)^3

        user_1 = UserPotential(f, g)
        user_2 = UserPotential(f)

        @fact user_1(3.0) => f(3)
        @fact user_2(3.0) => f(3)
        @fact force(user_1, 3.0) => g(3)
        @fact force(user_2, 3.0) => roughly(g(3), atol=10-6)
    end

    context("Short-range potential") do
        lj = LennardJones(0.8, 2.0)
        short = Potential(lj, cutoff=8.0)

        @fact short.cutoff => 8.0
        @fact short.e_cutoff => lj(8.0)
        @fact short(9) => 0.0
        @fact short(3.) => lj(3.0) + short.e_cutoff
    end

end
