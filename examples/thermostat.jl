using Jumos

# ============================================================================ #
#       Thermostating a simulation using a velocities rescale thermostat       #
# ============================================================================ #

sim = Simulation(:MD, 1.0)
universe = Universe(UnitCell(unit_from(10.0, "A")), Topology("lennard-jones.xyz"))
positions_from_file!(universe, "lennard-jones.xyz")
create_velocities!(universe, unit_from(130, "K"))


add_interaction!(universe, LennardJones(unit_from(0.2, "kJ/mol"), unit_from(2.0, "A")), "He", "He")
push!(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
push!(sim, EnergyOutput("LJ-energy.dat", 10))
# Adding the thermostat
push!(sim, VelocityRescaleThermostat(unit_from(300, "K"), unit_from(10, "K")))
propagate!(sim, universe, 500)

# ============================================================================ #
#           Thermostating a simulation using a Berendsen thermostat            #
# ============================================================================ #

sim = Simulation(:MD, 1.0)
universe = Universe(UnitCell(unit_from(10.0, "A")), Topology("lennard-jones.xyz"))
positions_from_file!(universe, "lennard-jones.xyz")
create_velocities!(universe, unit_from(100, "K"))


add_interaction!(universe, LennardJones(unit_from(0.2, "kJ/mol"), unit_from(2.0, "A")), "He", "He")
push!(sim, TrajectoryOutput("LJ-trajectory.xyz", 10))
push!(sim, EnergyOutput("LJ-energy.dat", 10))
# Adding the thermostat
push!(sim, BerendsenThermostat(unit_from(300, "K"), 50))
propagate!(sim, universe, 500)
