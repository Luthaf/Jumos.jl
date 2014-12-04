
sim = Simulation("MD", 1.0)

set_cell(sim, (8.0,))

top = Topology(2)
top[1] = Atom("He")
top[2] = Atom("He")

frame = Frame(top)
frame.positions[1] = [2., 2., 2.] + 0.1 .* rand(3)
frame.positions[2] = [2., 2., 4.] + 0.1 .* rand(3)
frame.cell = sim.cell

set_frame(sim, frame)

create_velocities(sim, 300)

add_interaction(sim, Harmonic(30, 2.0, -0.5), "He")

out_trajectory = TrajectoryOutput("traj.xyz", 1)
add_output(sim, out_trajectory)

run!(sim, 500)
