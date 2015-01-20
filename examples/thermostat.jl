using Jumos

# ============================================================================ #
#       Thermostating a simulation using a velocities rescale thermostat       #
# ============================================================================ #

sim = MolecularDynamic(1.0)
set_cell(sim, (10.0,))
read_topology(sim, "lennard-jones.xyz")
read_positions(sim, "lennard-jones.xyz")
create_velocities(sim, 300)


add_interaction(sim, LennardJones(0.8, 2.0), "He")
add_output(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
add_output(sim, EnergyOutput("LJ-energy.dat", 10))

add_enforce(sim, VelocityRescaleThermostat(300, 10))
run!(sim, 5000)

# ============================================================================ #
#           Thermostating a simulation using a Berendsen thermostat            #
# ============================================================================ #

sim = MolecularDynamic(1.0)
set_cell(sim, (10.0,))
read_topology(sim, "lennard-jones.xyz")
read_positions(sim, "lennard-jones.xyz")
create_velocities(sim, 300)


add_interaction(sim, LennardJones(0.8, 2.0), "He")
add_output(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
add_output(sim, EnergyOutput("LJ-energy.dat", 10))

add_enforce(sim, BerendsenThermostat(300, 50))
run!(sim, 5000)
