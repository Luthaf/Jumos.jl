#===============================================================================
                            Simulation Data storage
===============================================================================#


# Maybe merge with the Frame type in Jumos.Trajectories
type SimulationData
    step::Integer
    box::SimBox
    topology::Topology
    positions::Vector{Vect3D{Float32}}
    velocities::Vector{Vect3D{Float32}}
    forces::Vector{Vect3D{Float32}}
end
