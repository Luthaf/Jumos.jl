import Base: call, show

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

function call(pot::BasePotential, r::Float64)
    throw(NotImplementedError("No implementation provided for potential $pot."))
end

call(pot::BasePotential, r::Number) = call(pot, convert(Float64, r))


#==============================================================================#
# Null potential, for a system without interactions
type NullPotential <: ShortRangePotential
end

@inline function call(pot::NullPotential, r::Float64)
    return 0.0
end


#==============================================================================#
# User defined potential, without any parameter
type UserPotential <: ShortRangePotential
    f::Function
end

@inline function call(pot::UserPotential, r::Float64)
    return pot.potential.f(r)
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
