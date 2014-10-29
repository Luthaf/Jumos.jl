import Base: call

abstract BasePotential

function call(pot::BasePotential, r::Float64)
    throw(NotImplementedError("No implementation provided for potential $pot."))
end


# User defined potential, without any parameter
type UserPotential <: BasePotential
    f::Function
end

@inline function call(pot::UserPotential, r::Float64)
    return pot.f(r)
end


# Lennard-Jones potential, in the
# V = 4\epsilon( (\sigma/r)^12 - (\sigma/r)^6 )
type LennardJones <: BasePotential
    sigma::Float64
    epsilon::Float64
end

@inline function call(pot::LennardJones, r::Float64)
    s6 = (pot.sigma/r)^6
    return 4.0*pot.epsilon*(s6^2 - s6)
end
