# Some handy functions
function dummy_frame(n=4)
    top = Topology(n)
    for i=1:n
        top[i] = Atom("He")
    end

    side = round(n^(1/3)) # integer such as n <= side^3

    frame = Frame(top)
    nplaced = 0
    for i=0:side-1, j=0:side-1, k=0:side-1
        frame.positions[nplaced+1] = [2.0*i, 2.0*j, 2.0*k]
        nplaced += 1
        nplaced == n ? break : nothing
    end

    cell = UnitCell(side*2.0)
    frame.cell = cell
    return frame
end

function testing_simulation()
    sim = MolecularDynamic(1.0)
    set_frame(sim, dummy_frame())
    add_interaction(sim, LennardJones(0.8, 2.0), "He")
    create_velocities(sim, 300)
    return sim
end

include("simulations/potentials.jl")
include("simulations/molecular-dynamics.jl")
include("simulations/controls.jl")
