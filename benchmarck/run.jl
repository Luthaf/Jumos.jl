using Jumos

function run_jumos()
    tic()
    sim = Simulation(:MD, 1.0)
    universe = Universe(UnitCell(10.0), Topology("He-LJ.xyz"))
    positions_from_file!(universe, "He-LJ.xyz")
    create_velocities!(universe, unit_from(300, "K"))
    add_interaction!(universe, LennardJones(unit_from(0.3, "kJ/mol"), unit_from(2.0, "A")), "He", "He")
    propagate!(sim, universe, 5000)
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
