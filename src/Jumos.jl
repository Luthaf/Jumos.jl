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
    include("Array3D.jl")

    type NotImplementedError <: Exception
        message::String
    end
    Base.show(io::IO, e::NotImplementedError) = show(io, "Not implemented : $(e.message)")
    export NotImplementedError

    " The `Systems` module defines all the usefull types for storage of a molecular
    system definition. "
    @reexport module Systems
        using Jumos
        include("Universe/Universe.jl")
    end


    " The `Trajectories` module allow reading and writing trajectories to files."
    @reexport module Trajectories
        using Jumos

        include("Trajectories/Topology.jl")
        include("Trajectories/Trajectory.jl")
    end


    " The `Simulations` module defines functions for running an analysing simulations."
    @reexport module Simulations
        using Jumos
    #    include("Simulations/Analysis/Histograms.jl")
        include("Simulations/Simulations.jl")
    end


end # module
