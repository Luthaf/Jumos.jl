#===============================================================================
         Implementation of the XYZ trajectories Reader

    XYZ format is a text-based format, with atomic informations arranged as:
            <name> <x> <y> <z> [<vx> <vy> <vz>]
    The two first lines of each frame contains a comment header, and the number
    of atoms.
===============================================================================#

# The XYZReader type hold .xyz files
type XYZReader <: BaseReader
    nsteps::Integer
    current_step::Integer
    file::IOStream
    box::Box
    topology::Topology
    topology_read::Bool
end

# Constructor of XYZReader: open the file and get some informations
function XYZReader(filename::String, box={0,0,0})
    file = open(filename, "r")
    natoms = int(readline(file))
    seekstart(file)
    nlines = countlines(file)
    seekstart(file)
    nsteps = nlines/(natoms + 2)
    if !(nlines%(natoms + 2) == 0)
        error("Wrong number of lines in file $filename")
    end
    return XYZReader(nsteps, 0, file, box, Topology(natoms), false)
end

# Read a given step of am XYZ Trajectory
function read_frame!(traj::XYZReader, step::Integer, frame::Frame)
    if !(step == traj.current_step+1)
        go_to_step!(traj, step)
        traj.current_step = step
    end
    if step > traj.nsteps || step < 1
        max = traj.nsteps
        error("Can not read step $step. Maximum step: $max")
    end
    return read_next_frame!(traj, frame)
end

# Read the next step of a trajectory.
# Assume that the cursor is already at the good place.
# Return True if there is still some step to read, false otherwhile
function read_next_frame!(traj::XYZReader, frame::Frame)
    frame.natoms = int(readline(traj.file))
    readline(traj.file)  # comment
    frame.positions = zeros(Float64, 3, frame.natoms) # Clearing the arrays
    frame.labels = String[]
    for i = 1:frame.natoms
        line = readline(traj.file)
        label, position = read_atom_from_line(line)
        frame.positions[:, i] = position
        if !traj.topology_read
            traj.topology.atoms[i] = Atom(label)
        end
    end
    frame.box = traj.box
    frame.step = traj.current_step
    traj.current_step += 1
    if traj.current_step > traj.nsteps
        return false
    else
        return true
    end
end

# Read the atomic informations from a line of a XYZ file
function read_atom_from_line(line::String)
    sp = split(line)
    return (sp[1], [float(sp[2]), float(sp[3]), float(sp[4])])
end

# Move file cursor to the first line of the step.
function go_to_step!(traj::XYZReader, step::Integer)
    seekstart(traj.file)
    current = 1
    while current < step
        natoms = int(readline(traj.file))
        for i=1:(natoms + 1)
            readline(traj.file)
        end
        current+=1
    end
    return nothing
end
