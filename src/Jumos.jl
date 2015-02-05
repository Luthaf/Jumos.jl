# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Jumos module main file
# ============================================================================ #

module Jumos
    using Reexport

    using SIUnits
    include("Units.jl")
    include("Constants.jl")

    # This module define some basic types like 3D vectors
    @reexport module Universe
        using Jumos
        import Base: show

        include("Universe/PeriodicTable.jl")
        include("Universe/Atom.jl")
        include("Universe/Topology.jl")

        type NotImplementedError <: Exception
            message::String
        end

        function show(io::IO, e::NotImplementedError)
            show(io, "Not implemented : $(e.message)")
        end

        export NotImplementedError

        include("Universe/Array3D.jl")
        include("Universe/UnitCell.jl")
        include("Universe/Frame.jl")
        include("Universe/Distances.jl")
    end


    # This module allow reading and writing trajectories to files
    # A trajectory is built with a topology (atomic names and relations)
    # and some arrays of positions, velocities and forces.
    @reexport module Trajectories
        using Jumos

        include("Trajectories/Topology.jl")
        include("Trajectories/Trajectory.jl")
    end

    @reexport module Simulations
        using Jumos
        include("Simulations/Analysis/Histograms.jl")

        include("Simulations/MolecularDynamics.jl")
    end


end # module
