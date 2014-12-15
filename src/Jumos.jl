module Jumos
    using Reexport

    @reexport module Units
        using SIUnits
        include("Units/Units.jl")
        include("Units/Constants.jl")
    end

    using Jumos.Units.Constants

    # This module define Atom type and store periodic table informations
    @reexport module Atoms
        using Jumos: Units
        include("Atoms/Periodic.jl")
        include("Atoms/Atom.jl")
        include("Atoms/Topology.jl")
    end

    # This module define some basic types like 3D vectors
    @reexport module Universe
        using Jumos: Atoms, Units
        import Base: show

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
    end


    # This module allow reading and writing trajectories to files
    # A trajectory is built with a topology (atomic names and relations)
    # and some arrays of positions, velocities and forces.
    @reexport module Trajectories
        using Jumos: Universe, Atoms, Units

        include("Trajectories/Topology.jl")
        include("Trajectories/Trajectory.jl")
    end


    # This module offer functions to compute distances between atoms
    @reexport module PBC
        using Jumos: Universe, Trajectories, Units

        include("PBC/Distances.jl")
    end


    # This module provide utilities for analysing trajectories, either
    # while runnning or using trajectories files
    @reexport module Analysis
        using Jumos: Trajectories, PBC, Atoms, Universe, Units

        include("Analysis/Histograms.jl")
    end

    @reexport module Simulations
        using Jumos: Trajectories, PBC, Universe, Atoms, Units

        include("Simulations/MolecularDynamics.jl")
    end


end # module
