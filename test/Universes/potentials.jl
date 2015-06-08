# Testing potentials

facts("Potentials functions") do
    context("Harmonic potential") do
        harmonic = Harmonic(30, 2.0, 4.5)

        @fact harmonic(2.0) => -4.5
        @fact harmonic(4.0) => 55.5
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

    context("Angle harmonic potential") do
        harmonic = HarmonicAngle(30, 120.0)

        @fact harmonic(120.0) => 0.0
        @fact harmonic(122.0) => 60.0
        @fact force(harmonic, 120.0) => 0.0
        @fact force(harmonic, 122.0) => -60.0
    end

    context("Cosine harmonic potential") do
        coshar = CosineHarmonic(30, 120.0)

        @fact coshar(120.0) => roughly(0.0, 1e-12)
        @fact coshar(130.0) => 0.30582452219993356
        @fact force(coshar, 120.0) => roughly(0.0, 1e-12)
        @fact force(coshar, 130.0) => 2.999428819963821
    end

    context("Torsion potential") do
        torsion = Torsion(30, 60.0, 2)

        @fact torsion(60.0) => roughly(0.0, 1e-12)
        @fact torsion(240.0) => roughly(0.0, 1e-12)
        @fact torsion(70.0) => 1.8092213764227472
        @fact force(torsion, 60.0) => roughly(0.0, 1e-12)
        @fact force(torsion, 240.0) => roughly(0.0, 1e-12)
        @fact force(torsion, 70.0) => 20.521208599540124
    end
end

facts("Potentials computation") do
    lj = LennardJones(0.8, 2.0)
    f(x) = 3*(x-3.5)^4
    g(x) = 12*(x-3.5)^3

    user_1 = UserPotential(f, g)
    user_2 = UserPotential(f)
    harmonic = Harmonic(30, 2.0, -0.5)

    context("Cutoff computation") do
        short = CutoffComputation(lj, cutoff=8.0)

        @fact short.cutoff => 8.0
        @fact short.e_cutoff => lj(8.0)
        @fact short(9) => 0.0
        @fact short(3.0) => lj(3.0) + short.e_cutoff
        @fact force(short, 9) => 0.0
        @fact force(short, 3.0) => force(lj, 3.0)
    end

    context("Direct computation") do
        context("Pair potentials") do
            direct = DirectComputation(lj)
            @fact direct(3.0) => lj(3.0)
            @fact direct(13.0) => lj(13.0)
            @fact force(direct, 3.0) => force(lj, 3.0)
            @fact force(direct, 13.0) => force(lj, 13.0)
        end

        context("Bonded potentials") do
            direct = DirectComputation(harmonic)
            @fact direct(3.0) => harmonic(3.0)
            @fact force(direct, 3.0) => force(harmonic, 3.0)
        end

        context("User potentials") do
            direct = DirectComputation(user_1)
            @fact direct(3.0) => user_1(3.0)
            @fact force(direct, 3.0) => force(user_1, 3.0)
        end
    end

    context("Table computation") do
        context("Pair potentials") do
            table = TableComputation(lj, 1000, 12.0)
            @fact table(3.0) => roughly(lj(3.0))
            @fact force(table, 3.0) => roughly(force(lj, 3.0))

            @fact table(13.0) => 0.0
            @fact force(table, 13.0) => 0.0
        end

        context("Bonded potentials") do
            table = TableComputation(harmonic, 1000, 12.0)
            @fact table(3.0) => roughly(harmonic(3.0))
            @fact force(table, 3.0) => roughly(force(harmonic, 3.0))
        end

        context("User potentials") do
            table = TableComputation(user_1, 1000, 12.0)
            @fact table(3.0) => roughly(user_1(3.0))
            @fact force(table, 3.0) => roughly(force(user_1, 3.0))
        end
    end
end

facts("Force computation") do
    context("Get forces & total force is null") do
        universe = testing_universe_from_size(4)
        getforces = NaiveForces()
        forces = Jumos.Array3D(Float64, 4)
        getforces(universe, forces)
        tot_force = forces[1] + forces[2] + forces[3] + forces[4]

        @fact tot_force => roughly([0.0, 0.0, 0.0])
    end
end
