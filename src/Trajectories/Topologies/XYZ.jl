#===============================================================================
        Read the firt frame of an XYZ file and extract the atomic names.
===============================================================================#

function read_xyz_topology(filename::String)
    fd = open(filename)

    natoms = int(readline(fd))
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
