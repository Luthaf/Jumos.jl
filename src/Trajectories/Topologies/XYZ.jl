# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@doc "
Read the first frame of an XYZ file and extract the atomic names.
" ->
function read_xyz_topology(filename::String)
    fd = open(filename)

    natoms = parse(Int, readline(fd))
    topology = Topology(natoms)

    readline(fd)  # Comment line

    for i=1:natoms
        line = readline(fd)
        splited = split(line)
        topology[i] = Atom(splited[1])
    end
    close(fd)
    return topology
end
