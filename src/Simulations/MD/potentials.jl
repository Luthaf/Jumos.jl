import Base: call, show

type PotentialError <: Exception
    msg :: String
end
export PotentialError

function show(io::IO, e::PotentialError)
    print(io, "Potential Error : \n")
    print(io, e.msg)
end

abstract BasePotential
abstract ShortRangePotential <: BasePotential
abstract LongRangePotential <: BasePotential

type Potential{T<:BasePotential}
    potential::T
    cutoff::Float64
    e_cutoff::Float64
end

# The default cutoff is set in angstroms. Others units should be added after
function Potential(T, args...; cutoff=12.0)
    pot = T(args...)
    if isa(ShortRangePotential, T)
        e_cutoff = pot(cutoff)
    else
        e_cutoff = 0.0
        cutoff = 0.0
    end
    return Potential(pot, cutoff, e_cutoff)
end

@inline function call(pot::Potential{ShortRangePotential}, r::Number)
    r > pot.cutoff ? 0.0 : pot.potential(r)
end

# Todo: long range potentials
@inline function call(pot::Potential{LongRangePotential}, r::Number)
    throw(NotImplementedError("Long range potential not implemented"))
end

function show(io::IO, pot::Potential)
    SEP = "\t"
    potential_type = typeof(pot.potential)
    println(io, "Potential{$potential_type}")
    println(io, SEP, "cutoff: ", pot.cutoff)
    for name in names(potential_type)
        println(io, SEP, name, ": ", getfield(pot.potential, name))
    end
end

function call(::BasePotential, ::Float64)
    throw(NotImplementedError("No implementation provided for potential $pot."))
end

call(pot::BasePotential, r::Number) = call(pot, convert(Float64, r))

function force(::BasePotential, ::Float64)
    throw(NotImplementedError("No implementation provided for potential $pot."))
end

force(pot::BasePotential, r::Number) = force(pot, convert(Float64, r))

#==============================================================================#
# Null potential, for a system without interactions
type NullPotential <: ShortRangePotential
end

@inline function call(pot::NullPotential, r::Float64)
    return 0.0
end

@inline function force(::Potential{NullPotential}, ::Float64)
    return 0.0
end

#==============================================================================#
# User defined potential, without any parameter
type UserPotential <: ShortRangePotential
    potential::Function
    force::Function
end

# ForwardDiff allow automatic force generation from the potential
# F = - grad(U)
using ForwardDiff

function UserPotential(potential::Function)
    potential_arr(x) = potential(x[1])
    force_arr = forwarddiff_gradient(potential_arr, Float64, fadtype=:typed)
    try
        # Testing it with a random value. This may fail if the potential is
        # not defined in this point, but after all it is very likely to
        # fail at some point after.
        force_arr([1.0])
    catch
        throw(PotentialError(
            "Could not differentiate the User potential automatically.

            Please provide a force function."
        ))
    end
    force(x) = force_arr([x])
    return UserPotential(potential, force)
end

@inline function call(pot::UserPotential, r::Float64)
    return pot.potential.potential(r)
end

@inline function force(pot::Potential{UserPotential}, r::Float64)
    return pot.potential.force(r)
end


#==============================================================================#
# Lennard-Jones potential, in the
# V = 4\epsilon( (\sigma/r)^12 - (\sigma/r)^6 )
type LennardJones <: ShortRangePotential
    sigma::Float64
    epsilon::Float64
end

@inline function call(pot::LennardJones, r::Float64)
    s6 = (pot.sigma/r)^6
    return 4.0*pot.epsilon*(s6^2 - s6)
end

@inline function force(pot::Potential{LennardJones}, r::Float64)
    s6 = (pot.sigma/r)^6
    return 24.0*pot.epsilon*(s6 - 2*s6^2)
end
