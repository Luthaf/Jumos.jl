#===============================================================================
  Read a file produced by the VMD topotools plugins and extract the topology.
===============================================================================#

const N_ATOMS = r"([0-9]*)\s*atoms"
const N_BONDS = r"([0-9]*)\s*bonds"
const N_ANGLES = r"([0-9]*)\s*angles"
const N_DIHEDRALS = r"([0-9]*)\s*dihedrals"
const N_IMPROPERS = r"([0-9]*)\s*impropers"
const N_TYPES = r"([0-9]*)\s*atom types"
const NAMES = r"Pair Coeffs\n#\n(.*)\n\n# Bond Coeffs"s

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
    nangles = int(match(N_ANGLES, header).captures[1])
    ndihedrals = int(match(N_DIHEDRALS, header).captures[1])
    nimpropers = int(match(N_IMPROPERS, header).captures[1])

    topology = Topology(natoms)

    # Read the atoms section
    i = 0
    while i < natoms
        splitted = split(line)
        if length(splitted) >= 3
            index = int(splitted[1])
            molecule = splitted[2]
            atom_type = int(splitted[3])

            topology[index] = Atom(names[atom_type])
            try
                push!(topology.molecules[molecule], index)
            catch
                topology.molecules[molecule] = [index]
            end
            i += 1
        end
        line = readline(topology_file)
    end


    # Read the bonds section
    i = 0
    while i < nbonds
        splitted = split(line)
        if length(splitted) >= 4
            bond = (int(splitted[3]), int(splitted[4]))
            push!(topology.bonds, bond)
            i += 1
        end
        line = readline(topology_file)
    end

    # Read the angles section
    i = 0
    while i < nangles
        splitted = split(line)
        if length(splitted) >= 4
            angle = (int(splitted[3]), int(splitted[4]), int(splitted[5]))
            push!(topology.angles, angle)
            i += 1
        end
        line = readline(topology_file)
    end

    # Read the dihedrals section
    i = 0
    while i < ndihedrals
        splitted = split(line)
        if length(splitted) >= 4
            dihedral = (int(splitted[3]), int(splitted[4]),
                    int(splitted[5]), int(splitted[6]))
            push!(topology.dihedrals, dihedral)
            i += 1
        end
        line = readline(topology_file)
    end

    # Read the impropers section
    i = 0
    while i < ndihedrals
        splitted = split(line)
        if length(splitted) >= 4
            improper = (int(splitted[3]), int(splitted[4]),
                    int(splitted[5]), int(splitted[6]))
            push!(topology.impropers, improper)
            i += 1
        end
        line = readline(topology_file)
    end

    close(topology_file)
    return topology
end
