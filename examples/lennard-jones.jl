# Loading the Jumos module before anything else
using Jumos

# Molecular Dynamics with 1.0fs timestep
sim = MolecularDynamic(1.0)

# Create the simulation cell : cubic simulation cell with a width of 10A
set_cell(sim, (10.0,))

# Create the initial topology, positions and velocities
read_topology(sim, "lennard-jones.xyz")
read_positions(sim, "lennard-jones.xyz")
create_velocities(sim, 300)  # Initialize at 300K

# Add Lennard-Jones interactions between He atoms
add_interaction(sim, LennardJones(0.8, 2.0), "He")

out_trajectory = TrajectoryOutput("LJ-trajectory.xyz", 1)
add_output(sim, out_trajectory)
add_output(sim, EnergyOutput("LJ-energy.dat", 10))

run!(sim, 500)

# It is really easy to change some parameters if you bind them to variables
out_trajectory.frequency = 10

run!(sim, 5000)

# Simulation scripts are normal Julia scripts !
println("All done")
