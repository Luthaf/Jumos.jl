# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

const N_ATOMS = r"([0-9]*)\s*atoms"
const N_BONDS = r"([0-9]*)\s*bonds"
const N_TYPES = r"([0-9]*)\s*atom types"
const NAMES = r"Pair Coeffs\n#\n(.*)\n\n# Bond Coeffs"s

@doc "
Read a file produced by the VMD topotools plugins and extract the topology.
" ->
function read_lmp_topology(filename::String)
    topology_file = open(filename)

    # Read the header
    line = readline(topology_file)
    header = ""
    while !ismatch(r"Atoms", line)
        header = string(header, line)
        line = readline(topology_file)
    end

    # Read atom names
    # Very specific to topotools
    names_content = split(match(NAMES, header).captures[1], '\n')
    ntypes = int(match(N_TYPES, header).captures[1])
    names = Array(String, ntypes)

    try
        for s in names_content
            spt = split(s)
            names[int(spt[2])] = spt[3]
        end
    catch
        # Using numbers as names
        names = [string(i) for i=1:ntypes]
    end

    # Interresting constants
    natoms = int(match(N_ATOMS, header).captures[1])
    nbonds = int(match(N_BONDS, header).captures[1])

    topology = Topology(natoms)

    # Read the atoms section
    n = 0
    while n < natoms
        splitted = split(line)
        if length(splitted) >= 3
            n += 1
            atom_type = int(splitted[3])
            topology[n] = Atom(names[atom_type])
        end
        line = readline(topology_file)
    end

    # Read the bonds section
    n = 0
    while n < nbonds
        splitted = split(line)
        if length(splitted) >= 4
            (i, j) = (int(splitted[3]), int(splitted[4]))
            add_liaison!(topology, i, j)
            n += 1
        end
        line = readline(topology_file)
    end

    close(topology_file)
    return topology
end
