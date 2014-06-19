module MolecularAnalysis

    module Topologies
        include("Topology.jl")

        export Topology, Atom, Bond, Angle, Dihedral
    end

    module Trajectories
        using MolecularAnalysis.Topologies
        include("Trajectory.jl")
        export MDTrajectory, BaseReader, BaseWriter, Box, Frame
    end

    importall .Topologies
    #export MDTrajectory, BaseReader, BaseWriter, Box, Frame
end

#=


export XYZReader, NCReader
export read_frame!, read_next_frame!, go_to_step, opentraj

include("Histograms/Histograms.jl")
export Histogram, DensityProfile
export update!, normalize!, write, clean!

end
=#
