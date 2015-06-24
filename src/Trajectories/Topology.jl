# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                       Topologie read and write
# ============================================================================ #
export topology_from_file!

@doc "
`read_topology!(universe, filename)`

Read the topology from the file `filename` into the `universe.topology`.
" ->
function read_topology!(universe, filename)
    universe.topology = read_topology(filename)
end

"
`Topology(filename)`

Read the topology from the file `filename` and return it.
"
function Universes.Topology(filename)
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

function topology_from_file!(univ::Universe, filename::AbstractString)
    univ.topology = Topology(filename)
end

include("Topologies/XYZ.jl")
