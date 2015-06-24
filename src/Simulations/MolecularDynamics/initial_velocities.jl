# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                            Initialize velocities
# ============================================================================ #

using Jumos.Constants # kB
export create_velocities!

function create_velocities!(univ::Universe, temp::Number; initializer="boltzman")
    # Allocate the velocity array
    univ.frame.velocities = Array3D(Float64, size(univ.frame))

    function_name = "init_" * initializer * "_velocities"
    funct = eval(Symbol(function_name))

    # Get masses
    get_masses!(univ)
    check_masses(univ)

    funct(univ, temp)
    univ.data[:temperature] = temp
end

function init_boltzman_velocities(univ::Universe, temp::Number)
    velocities = univ.frame.velocities
    masses = univ.masses
    @inbounds for i=1:size(univ.frame)
        velocities[i] = rand_vel_boltzman(masses[i], temp)
    end
end

@inline function rand_vel_boltzman(m, T)
    return sqrt(kB*T/m)*randn(3)
end

function init_random_velocities(univ::Universe, temp::Number)
    velocities = univ.frame.velocities
    masses = univ.masses
    @inbounds for i=1:size(univ.frame)
        velocities[i] = rand_vel(masses[i], temp)
    end
end

@inline function rand_vel(m, T)
    vel = 2.0 .* rand(3) .- 1.0
    return sqrt(3*kB*T/m) .* vel
end
