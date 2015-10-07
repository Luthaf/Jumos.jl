# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Jumos module main file
# ============================================================================ #

module Jumos
    warn("Jumos is deprecated! You should not use it. Please see cymbalum for a successor of Jumos: https://github.com/Luthaf/cymbalum")
    using Reexport

    @reexport module Units
        include("Units.jl")
        include("Constants.jl")
        export Constants
    end

    include("Array3D.jl")
    using Jumos.Units, Jumos.Arrays

    type NotImplementedError <: Exception
        message::String
    end
    Base.show(io::IO, e::NotImplementedError) = show(io, "Not implemented : $(e.message)")
    export NotImplementedError

    type JumosError <: Exception
        message::String
    end
    Base.show(io::IO, e::JumosError) = show(io, e.message)
    export JumosError

    " The `Systems` module defines all the usefull types for storage of a molecular
    system definition. "
    @reexport module Universes
        using Jumos, Jumos.Units, Jumos.Arrays
        include("Universe/Universe.jl")
    end

    " The `Trajectories` module allow reading and writing trajectories to files."
    @reexport module Trajectories
        using Jumos, Jumos.Units, Jumos.Arrays

        include("Trajectories/Topology.jl")
        include("Trajectories/Trajectory.jl")
    end

    " The `Simulations` module defines functions for running an analysing simulations."
    @reexport module Simulations
        using Jumos, Jumos.Units, Jumos.Arrays
        include("Simulations/Simulations.jl")
        include("Simulations/MolecularDynamics.jl")

        # include("Simulations/Analysis/Histograms.jl")
    end
end
