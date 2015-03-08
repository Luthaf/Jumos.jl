using Jumos

# ============================================================================ #
#       Thermostating a simulation using a velocities rescale thermostat       #
# ============================================================================ #

sim = Simulation(:MD, 1.0)
universe = Universe(UnitCell(10.0), Topology("lennard-jones.xyz"))
positions_from_file!(universe, "lennard-jones.xyz")
create_velocities!(universe, 300)


add_interaction!(universe, LennardJones(0.8, 2.0), "He", "He")
push!(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
push!(sim, EnergyOutput("LJ-energy.dat", 10))
# Adding the thermostat
push!(sim, VelocityRescaleThermostat(300, 10))
propagate!(sim, universe, 500)

# ============================================================================ #
#           Thermostating a simulation using a Berendsen thermostat            #
# ============================================================================ #

sim = Simulation(:MD, 1.0)
universe = Universe(UnitCell(10.0), Topology("lennard-jones.xyz"))
positions_from_file!(universe, "lennard-jones.xyz")
create_velocities!(universe, 300)


add_interaction!(universe, LennardJones(0.8, 2.0), "He", "He")
push!(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
push!(sim, EnergyOutput("LJ-energy.dat", 10))
# Adding the thermostat
push!(sim, BerendsenThermostat(300, 50))
propagate!(sim, universe, 500)
