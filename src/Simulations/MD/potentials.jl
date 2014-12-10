import Base: call, show
export PotentialError, BasePotential, ShortRangePotential, Potential
export UserPotential, LennardJones, Harmonic
export force

type PotentialError <: Exception
    msg :: String
end

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
function Potential(pot::BasePotential; cutoff=12.0)
    if typeof(pot) <: ShortRangePotential
        e_cutoff = pot(cutoff)
    else
        e_cutoff = 0.0
        cutoff = 0.0
    end
    return Potential(pot, cutoff, e_cutoff)
end

function Potential(T, args...; cutoff=12.0)
    pot = T(args...)
    return Potential(pot, cutoff=cutoff)
end

@inline function call{T<:ShortRangePotential}(pot::Potential{T}, r::Real)
    r > pot.cutoff ? 0.0 : pot.potential(r) + pot.e_cutoff
end

@inline function force{T<:ShortRangePotential}(pot::Potential{T}, r::Real)
    r > pot.cutoff ? 0.0 : force(pot.potential, r)
end

# Todo: long range potentials
function call(::Potential{LongRangePotential}, ::Real)
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

function call(pot::BasePotential, ::Real)
    throw(NotImplementedError("No implementation provided for potential $pot."))
end

call(pot::BasePotential, r::Real) = call(pot, convert(Float64, r))

function force(pot::BasePotential, ::Real)
    throw(NotImplementedError("No force method provided for potential $pot."))
end

force(pot::BasePotential, r::Real) = force(pot, convert(Float64, r))


@doc "
Null potential, for a system without interactions
" ->
type NullPotential <: ShortRangePotential
end

function call(::NullPotential, ::Float64)
    return 0.0
end

@inline function force(::NullPotential, ::Float64)
    return 0.0
end


@doc "
User defined potential, without any parameter
" ->
type UserPotential <: ShortRangePotential
    potential::Function
    force::Function
end

# Calculus allow automatic force computation using finite difference
using Calculus # derivative

function UserPotential(potential::Function)
    force(x) = - derivative(potential)(x)
    return UserPotential(potential, force)
end

@inline function call(pot::UserPotential, r::Real)
    return pot.potential(r)
end

@inline function force(pot::UserPotential, r::Real)
    return pot.force(r)
end


# @doc "
# Lennard-Jones potential, using the following formulation
#    \[ V(r) = 4\epsilon( (\sigma/r)^12 - (\sigma/r)^6 ) \]
# " ->
type LennardJones <: ShortRangePotential
    epsilon :: Float64
    sigma   :: Float64
end

@inline function call(pot::LennardJones, r::Real)
    s6 = (pot.sigma/r)^6
    return 4.0*pot.epsilon*(s6^2 - s6)
end

@inline function force(pot::LennardJones, r::Real)
    s6 = (pot.sigma/r)^6
    return -24.*pot.epsilon*(s6 - 2*s6^2)/r
end


# @doc "
# Harmonic potential, with the following definition :
#     \[ V(r) = \frac12 k (r - r_0) - D_0 \]
#
# `Harmonic(k, r0, depth=0.0)`
#
#     This function creates an instance of an Harmonic potential.
# " ->
type Harmonic <: ShortRangePotential
    k     :: Float64
    r0    :: Float64
    depth :: Float64
end

Harmonic(k::Real, r0::Real) = Harmonic(k, r0, 0.0)

@inline function call(pot::Harmonic, r::Real)
    return 0.5 * pot.k * (r - pot.r0)^2 + pot.depth
end

@inline function force(pot::Harmonic, r::Real)
    return - pot.k * (r - pot.r0)
end
