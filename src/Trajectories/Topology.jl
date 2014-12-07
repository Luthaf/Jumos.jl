#===============================================================================
                        Topologie read and write
===============================================================================#
export read_topology

include("Topologies/XYZ.jl")
include("Topologies/LAMMPS.jl")

function read_topology(filename)
    extension = split(strip(filename), ".")[end]
    if extension == "xyz"
        info("Reading topology in XYZ format")
        return read_xyz_topology(filename)
    elseif extension == "lmp"
        info("Reading topology in LAMMPS format")
        return read_lmp_topology(filename)
    else
        error("The '$extension' extension is not recognized")
    end
end

import Jumos: Topology
Topology(filename::String) = read_topology(filename)
