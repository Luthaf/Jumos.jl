#!/usr/bin/env julia

# Loading the Jumos module before anything else
using Jumos

# Molecular Dynamics with 1.0fs timestep
sim = Simulation(:MD, 1.0)

# Create a cubic cell with a width of 10A
cell = UnitCell(unit_from(10.0, "A"))
# Read a topology from a file
topology = Topology("lennard-jones.xyz")
# Create an universe from the cell and the topology

universe = Universe(cell, topology)
positions_from_file!(universe, "lennard-jones.xyz")
# Initialize random velocities at 300K
create_velocities!(universe, 300)

# Add Lennard-Jones interactions between He atoms
add_interaction!(
    universe,
    LennardJones(unit_from(0.2, "kJ/mol"), unit_from(2.0, "A")),
    "He", "He"
)

# You can either bind algorithms to variables ...
out_trajectory = TrajectoryOutput("LJ-trajectory.xyz", 1)
push!(sim, out_trajectory)
# ... or create them directly in function call
push!(sim, EnergyOutput("LJ-energy.dat", 10))

propagate!(sim, universe, 5000)

# Simulation scripts are normal Julia scripts !
println("All done")
