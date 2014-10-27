#===============================================================================
                Read an XYZ file and extract the atomic names.
===============================================================================#

function read_xyz_topology(filename::String)
    f = open(filename)

    natoms = int(readline(f))
    t = Topology(natoms)

    readline(f)  # Comment line

    for i=1:natoms
        line = readline(f)
        sp = split(line)
        t.atoms[i] = Atom(sp[1])
    end
    close(f)
    return t
end
