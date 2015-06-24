# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                    Potentials: energy and forces primitives
# ============================================================================ #

export PotentialError
export PotentialFunction, PairPotential, BondedPotential, AnglePotential,
       DihedralPotential, ShortRangePotential, LongRangePotential
export PotentialComputation, DirectComputation, CutoffComputation,
       LongRangeComputation, TableComputation

export UserPotential, LennardJones, Harmonic, NullPotential
export HarmonicAngle, CosineHarmonic
export Torsion
export force

type PotentialError <: Exception
    msg :: String
end

function Base.show(io::IO, e::PotentialError)
    print(io, "Potential Error : \n")
    print(io, e.msg)
end

@doc "
A `PotentialFunction` is an effective implementation of a potential energy and
forces function.
" ->
abstract PotentialFunction

@doc "
A `PotentialComputation` is a way to compute interactions.
" ->
abstract PotentialComputation{T<:PotentialFunction}

# ============================================================================ #

@doc "
A `PairPotential` is an interaction between two particle, with no range limit,
going to zero as the distance goes to infinity.
" ->
abstract PairPotential <: PotentialFunction

@doc doc"
Short-range potential are functions going to zero faster than the $1/r^3$ function.
" ->
abstract ShortRangePotential <: PairPotential

@doc doc"
Long-range potential are functions going to zero slower than the $1/r^3$ function.
" ->
abstract LongRangePotential <: PairPotential

@doc "
A `BondedPotential` is an interaction between two particle, with a range limit.
This interaction goes to infinity when the distance goes to zero or to infinity.
" ->
abstract BondedPotential <: PotentialFunction

@doc "
An `AnglePotential` is an interaction between three particle, computed using the
angle between these particles.
" ->
abstract AnglePotential <: PotentialFunction

@doc "
A `DihedralPotential` is an interaction between four particle, computed using the
two dihedral angles.
" ->
abstract DihedralPotential <: PotentialFunction

typealias Potential2Body Union(PairPotential, BondedPotential)

# ============================================================================ #

@doc "
The `DirectComputation` of a potential can always be used, but may not be the
most effective way.
" ->
immutable DirectComputation{T<:PotentialFunction} <: PotentialComputation{T}
    potential::T
end

@doc "
A `CutoffComputation` of an interaction use a cutoff distance. After this distance,
the energy and the force are set to be zero.
" ->
immutable CutoffComputation{T<:ShortRangePotential} <: PotentialComputation{T}
    potential::T
    cutoff::Float64
    e_cutoff::Float64
end

@doc doc"
`LongRangeComputation` should be used for pair potential which goes to zero slower
than the $1/r^3$ function.
" ->
abstract LongRangeComputation{T<:LongRangePotential} <: PotentialComputation{T}

@doc "
`TableComputation` uses table lookup to compute pair interactions efficiently.

A linear interpolation is used.
" ->
immutable TableComputation{T<:PotentialFunction, N} <: PotentialComputation{T}
    potential::Array{Float64, 1}
    force::Array{Float64, 1}
    rmax::Float64
    dr::Float64
end

# ============================================================================ #
#                           Fallback methods
# ============================================================================ #

function Base.call(p::PotentialComputation, ::Real)
    throw(NotImplementedError(
        "The potential computation $(typeof(p)) is not implemented."
    ))
end

function force(p::PotentialComputation, ::Real)
    throw(NotImplementedError(
        "The force computation for $(typeof(p)) is not implemented."
    ))
end

function Base.call(pot::PotentialFunction, ::Real)
    throw(NotImplementedError("No call method provided for potential $pot.\n
                               Please provide this method."))
end

function force(pot::PotentialFunction, ::Real)
    throw(NotImplementedError("No force method provided for potential $pot.\n
                               Please provide this method."))
end

# Convert everything to Float64
Base.call(pot::PotentialFunction, r::Real) = call(pot, convert(Float64, r))
force(pot::PotentialFunction, r::Real) = force(pot, convert(Float64, r))

# ============================================================================ #
#                        Computations implementations
# ============================================================================ #

function CutoffComputation(pot::PotentialFunction; cutoff=12.0)
    e_cutoff = pot(cutoff)
    return CutoffComputation(pot, cutoff, e_cutoff)
end

@inline function Base.call{T<:ShortRangePotential}(pot::CutoffComputation{T}, r::Real)
    r > pot.cutoff ? 0.0 : pot.potential(r) + pot.e_cutoff
end

@inline function force{T<:ShortRangePotential}(pot::CutoffComputation{T}, r::Real)
    r > pot.cutoff ? 0.0 : force(pot.potential, r)
end

# Only the default constructor is needed for DirectComputation(::PotentialFunction)

@inline function Base.call(pot::DirectComputation, r::Real)
    return pot.potential(r)
end

@inline function force(pot::DirectComputation, r::Real)
    return force(pot.potential, r)
end


function TableComputation{T<:PotentialFunction}(pot::T, N::Integer, rmax::Real)
    dr = float(rmax)/N
    x = linspace(dr, rmax, N)
    potential_array = map(pot, x)
    force_array = map(u->force(pot, u), x)

    return TableComputation{T, N}(potential_array, force_array, rmax, dr)
end

# Keyword version of the function
function TableComputation{T<:PotentialFunction}(pot::T; numpoints=2000, rmax=12)
    return TableComputation(pot, numpoints, rmax)
end

@inline function Base.call{T, N}(pot::TableComputation{T, N}, r::Real)
    bin = floor(Int, r/pot.dr)
    bin < N ? nothing : return 0.0
    delta = r - bin*pot.dr
    slope = (pot.potential[bin + 1] - pot.potential[bin])/pot.dr
    return pot.potential[bin] + delta*slope
end

@inline function force{T, N}(pot::TableComputation{T, N}, r::Real)
    bin = floor(Int, r/pot.dr)
    bin < N ? nothing : return 0.0
    delta = r - bin*pot.dr
    slope = (pot.force[bin + 1] - pot.force[bin])/pot.dr
    return pot.force[bin] + delta*slope
end

# TODO: PPPM <: LongRangeComputation
# TODO: EwaldSumation <: LongRangeComputation

# ============================================================================ #
#                           Potential functions
# ============================================================================ #

@doc "
Null potential, for a system without interactions
" ->
immutable NullPotential <: PairPotential end

function Base.call(::NullPotential, ::Float64)
    return 0.0
end

@inline function force(::NullPotential, ::Float64)
    return 0.0
end

# ============================================================================ #

@doc "
User defined potential, without any parameter
" ->
immutable UserPotential <: ShortRangePotential
    potential::Function
    force::Function
end

# Calculus allow automatic force computation using finite difference
import Calculus

function UserPotential(potential::Function)
    force(x) = - Calculus.derivative(potential)(x)
    return UserPotential(potential, force)
end

@inline function Base.call(pot::UserPotential, r::Real)
    return pot.potential(r)
end

@inline function force(pot::UserPotential, r::Real)
    return pot.force(r)
end

# ============================================================================ #

@doc doc"
Lennard-Jones potential, using the following formulation
   \[ V(r) = 4\epsilon( (\sigma/r)^12 - (\sigma/r)^6 ) \]
" ->
immutable LennardJones <: ShortRangePotential
    epsilon :: Float64
    sigma   :: Float64
end

@inline function Base.call(pot::LennardJones, r::Real)
    s6 = (pot.sigma/r)^6
    return 4.0*pot.epsilon*(s6^2 - s6)
end

@inline function force(pot::LennardJones, r::Real)
    s6 = (pot.sigma/r)^6
    return -24.*pot.epsilon*(s6 - 2*s6^2)/r
end

# ============================================================================ #

@doc doc"
Harmonic potential, with the following definition :
    \[ V(r) = \frac12 k (r - r_0) - D_0 \]

`Harmonic(k, r0, depth=0.0)`
    This function creates an instance of an Harmonic potential.
" ->
immutable Harmonic <: BondedPotential
    k     :: Float64
    r0    :: Float64
    depth :: Float64
end

Harmonic(k::Real, r0::Real) = Harmonic(k, r0, 0.0)

@inline function Base.call(pot::Harmonic, r::Real)
    return 0.5 * pot.k * (r - pot.r0)^2 - pot.depth
end

@inline function force(pot::Harmonic, r::Real)
    return pot.k * (pot.r0 - r)
end

# ============================================================================ #

@doc doc"
Harmonic angle potential, with the following definition :
    \[ V(\theta) = \frac12 k (\theta - \theta_0) \]

`Harmonic(k, θ)`
    This function creates an instance of an HarmonicAngle potential.
" ->
immutable HarmonicAngle <: AnglePotential
    k :: Float64
    θ :: Float64
end

@inline function Base.call(pot::HarmonicAngle, θ::Real)
    return 0.5 * pot.k * (θ - pot.θ)^2
end

@inline function force(pot::HarmonicAngle, θ::Real)
    return pot.k * (pot.θ - θ)
end

# ============================================================================ #

@doc doc"
Cosine harmonic angle potential, with the following definition :
    \[ V(\theta) = \frac12 k (\cos(\theta) - \cos(\theta_0)) \]

`CosineHarmonic(k, θ)`
    This function creates an instance of an CosineHarmonic potential.
" ->
immutable CosineHarmonic <: AnglePotential
    k :: Float64
    θ :: Float64  # in degree
    CosineHarmonic(k, θ) = new(k, deg2rad(θ))
end

@inline function Base.call(pot::CosineHarmonic, θ::Real)
    return 0.5 * pot.k * (cosd(θ) - cos(pot.θ))^2
end

@inline function force(pot::CosineHarmonic, θ::Real)
    return pot.k * (sin(pot.θ) - sind(θ))
end

# ============================================================================ #

@doc doc"
Torsion dihedral angle potential, with the following definition :
    \[ V(\phi) = k (1 + n \cos( m \phi - \phi_0)) \]

`Torsion(k, ϕ, m, [n=-1])`
    This function creates an instance of an Torsion potential, with a default
    value of 1 for the n coefficient.
" ->
immutable Torsion{n, m} <: DihedralPotential
    k :: Float64
    ϕ :: Float64
end

Torsion(k::Real, ϕ::Real, m::Integer, n::Integer=-1) = Torsion{n, m}(k, ϕ)

@inline function Base.call{n, m}(pot::Torsion{n, m}, ϕ::Real)
    return pot.k * (1 + n * cosd(m*(ϕ - pot.ϕ)))
end

@inline function force{n, m}(pot::Torsion{n, m}, ϕ::Real)
    return -1 * pot.k * n * m * sind(m*(ϕ - pot.ϕ))
end
