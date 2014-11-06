using Jumos

# Molecular Dynamics with 2.0fs timestep
sim = Simulation("MD", 2.0)

# Create the simulation box : cubic simulation box with a width of 20A
create_box(sim, 20.0)

# Create the initial topology, positions and velocities
read_topology(sim, "lennard-jones.xyz")
read_positions(sim, "lennard-jones.xyz")
create_velocities(sim, 300)  # Initialize at 300K

# Add Lennard-Jones interactions between He atoms
add_interaction(sim, LennardJones(0.3, 2.0), ("He", "He"))

out_trajectory = TrajectryOutput("LJ-traj.xyz", 1)
add_output(sim, out_trajectory)

add_output(sim, EnergyOutput(sim, 10))

run!(sim, 500)

# It is really easy to change some parameters if you bind them to variables
out_trajectory.frequency = 10

run!(sim, 5000)

# Simulation scripts are normal julia scripts !
println("All done")
