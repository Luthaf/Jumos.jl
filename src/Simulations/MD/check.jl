#===============================================================================
                    Checking the simulation consistency
===============================================================================#
import Base: show, call
export BaseCheck
export ParticleNumberIsConstant, GlobalVelocityIsNull, TotalForceIsNull
# abstract BaseCheck -> Defined in MolecularDynamics.jl

function show(io::IO, a::BaseCheck)
    show(io, typeof(a))
end

type CheckError <: Exception
    msg :: String
end
export CheckError

function show(io::IO, e::CheckError)
    print(io, "Error in simulation : \n")
    print(io, e.msg)
end


@doc "
Check if all the positions and all the velocities are number : not NaN neither Inf.
" ->
type AllPositionsAreDefined <: BaseCheck
end

function call(::AllPositionsAreDefined, sim::MDSimulation)
    const natoms = size(sim.frame)
    for i=1:natoms, j=1:3
        isfinite(sim.frame.positions[j, i]) || throw(CheckError(
            "All positions are not defined."
        ))
    end
    for i=1:natoms, j=1:3
        isfinite(sim.frame.velocities[j, i]) || throw(CheckError(
            "All velocities are not defined."
        ))
    end
end


type ParticleNumberIsConstant <: BaseCheck
end

type GlobalVelocityIsNull <: BaseCheck
end

type TotalForceIsNull <: BaseCheck
end
