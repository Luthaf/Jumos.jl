module MolecularAnalysis

    include("vect3.jl")
    export Vect3

    include("Periodic.jl")
    export ATOMIC_MASSES, VDW_RADIUS

    include("Topology.jl")
    export Topology, Atom, Bond, Angle, Dihedral
    export read_topology

    include("Trajectory.jl")
    export MDTrajectory, BaseReader, BaseWriter, Box, Frame
    export XYZReader, NCReader
    export read_frame!, read_next_frame!, go_to_step, opentraj, eachframe
    export close, isopen

    include("Distances.jl")
    export minimal_image!, pbc_distance, distance, distance_array

    include("Histograms.jl")
    export Histogram, DensityProfile, RDF
    export update!, normalize!, write, clean!

end
