# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                            Initialize velocities
# ============================================================================ #

using Jumos.Constants # kB
export create_velocities

function create_velocities(sim::MolecularDynamic, temp::Integer; initializer="boltzman")
    # Allocate the velocity array
    sim.frame.velocities = Array3D(Float64, size(sim.frame))

    function_name = "init_" * initializer * "_velocities"
    funct = eval(Symbol(function_name))

    # Get masses
    sim.masses = atomic_masses(sim.topology)
    check_masses(sim)

    funct(sim, temp)

    sim.data[:temperature] = temp
end

function init_boltzman_velocities(sim::MolecularDynamic, temp::Integer)
    velocities = sim.frame.velocities
    masses = sim.masses
    @inbounds for i=1:size(sim.frame)
        velocities[i] = rand_vel_boltzman(masses[i], temp)
    end
end

@inline function rand_vel_boltzman(m, T)
    return sqrt(kB*T/m)*randn(3)
end

function init_random_velocities(sim::MolecularDynamic, ::Integer)
    velocities = sim.frame.velocities
    @inbounds for i=1:size(sim.frame)
        velocities[i] = rand_vel()
    end
end

@inline function rand_vel()
    return 2.*rand(3) .- 1
end
