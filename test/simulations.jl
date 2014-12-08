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

set_cell(sim, (8.0,))

top = Topology(2)
top[1] = Atom("He")
top[2] = Atom("He")

frame = Frame(top)
frame.positions[1] = [2., 2., 2.]
frame.positions[2] = [2., 2., 4.2]
frame.cell = sim.cell

set_frame(sim, frame)

# Setup null velocities
create_velocities(sim, 0)

add_interaction(sim, LennardJones(0.8, 2.0), "He")

run!(sim, 1)

@test sim.forces[1] .+ sim.forces[2] == [0.0, 0.0, 0.0]
fval = -0.6352381559296235e-4
@test isapprox([sim.forces[1]...], [0.0, 0.0, fval])

m = sim.masses[1]
@test m == ATOMIC_MASSES["He"].val

@test isapprox([sim.frame.velocities[1]...], [0.0, 0.0, 0.5*fval/m])

tmpname = tempname() * ".xyz"
out_trajectory = TrajectoryOutput(tmpname, 1)
add_output(sim, out_trajectory)

run!(sim, 500)

rm(tmpname)
