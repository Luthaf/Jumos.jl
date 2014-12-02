using Jumos

function run_jumos()
    tic()
    sim = Simulation("MD", 1.0)
    set_cell(sim, (10.0,))
    read_topology(sim, "He-LJ.xyz")
    read_positions(sim, "He-LJ.xyz")
    create_velocities(sim, 300)  # Initialize at 300K

    add_interaction(sim, LennardJones(0.3, 2.0), "He")

    run!(sim, 5000)
    return toq()
end

function run_lammps()
    LAMMPS_NAMES = ["lammps", "lmp", "lmp-mpi", "lmp-g++"]
    lammps_name = ""
    for name in LAMMPS_NAMES
        try
            run(`which $name`)
        catch
            continue
        end
        lammps_name = name
    end
    cmd = `$lammps_name -in Lammps.in`
    tic()
    run(cmd)
    return toq()
end

function main()
    cd(dirname(@__FILE__))

    lammps_time = run_lammps()
    jumos_time = run_jumos()

    println("LAMMPS: ", lammps_time, "s")
    println("Jumos: ", jumos_time, "s")
    println("ratio: ", jumos_time/lammps_time)

    rm("log.lammps")
end

main()
