# Testing potentials

harmonic = Harmonic(30, 2.0, -0.5)

@test harmonic(2.0) == -0.5
@test harmonic(4.0) == 59.5
@test force(harmonic, 2.0) == 0.0
@test force(harmonic, 3.0) == -30.0 # force in kJ/(mol*A)

lj = LennardJones(0.8, 2.0)
@test lj(2.0) == 0.0
@test lj(2.5) == -0.6189584744448002
@test isapprox(force(lj, 2^(1./6.)*2.0), 0.0, atol=1e-15)
@test isapprox(force(lj, 2.5), -0.95773475733504, atol=1e-15) # force in kJ/(mol*A)

f(x) = 3*(x-3.5)^4
g(x) = 12*(x-3.5)^3

user_1 = UserPotential(f, g)
user_2 = UserPotential(f)

@test user_1(3.0) == f(3)
@test user_2(3.0) == f(3)
@test force(user_1, 3.0) == g(3)
@test isapprox(force(user_1, 3.0), g(3))

short = Potential(lj, cutoff=8.0)
@test short.cutoff == 8.0
@test short.e_cutoff == lj(8.0)
@test short(9) == 0.0
@test short(3.) == lj(3.0) + short.e_cutoff

# Test the simulations
sim = Simulation("MD", 1.0)

top = Topology(4)
for i=1:4
    top[i] = Atom("He")
end

frame = Frame(top)
for i=1:4
    frame.positions[i] = [2.*i, 2.*(i%2), 2.*(i%3)]
end

cell = UnitCell(8.0)
frame.cell = cell
set_frame(sim, frame)

add_interaction(sim, LennardJones(0.8, 2.0), "He")

Simulations.get_forces!(sim)
tot_force = sim.forces[1] .+ sim.forces[2] .+ sim.forces[3] .+ sim.forces[4]
@test isapprox(tot_force, [0.0, 0.0, 0.0])

create_velocities(sim, 300)

tmpname = tempname() * ".xyz"
out_trajectory = TrajectoryOutput(tmpname, 1)
add_output(sim, out_trajectory)

energy = EnergyCompute()
T = TemperatureCompute()

# This is a pretty large interval, but there are few atoms here
@test 10 < T(sim) < 1000

Ekin, Epot, Etot = energy(sim)

@test Ekin + Epot == Etot

run!(sim, 500)

Ekin_f, Epot_f, Etot_f = energy(sim)

@test isapprox(Etot_f, Etot, rtol=1e-3)

rm(tmpname)
