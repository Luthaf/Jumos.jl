#===============================================================================
                            Simulation box type
===============================================================================#

export SimBox, InfiniteBox, OrthorombicBox, TriclinicBox

abstract AbstractBoxType
type InfiniteBox <: AbstractBoxType end
type OrthorombicBox <: AbstractBoxType end
type TriclinicBox <: AbstractBoxType end

immutable SimBox{T<:AbstractBoxType}
    length :: Vect3D{Float64}
    angles :: Vect3D{Float64}
    box_type :: T
end

function getindex(b::SimBox, i::Int)
    if 0 < i <= 3
        return b.length[i]
    elseif 3 < i <= 6
        return b.angles[i-3]
    end
    throw(BoundsError())
end

function getindex(b::SimBox, i::String)
    i = lowercase(i)
    if i == "x"
        return b.length[1]
    elseif i == "y"
        return b.length[2]
    elseif i == "z"
        return b.length[3]
    elseif i == "alpha"
        return b.angles[1]
    elseif i == "beta"
        return b.angles[2]
    elseif i == "gamma"
        return b.angles[3]
    end
    throw(BoundsError())
end

function SimBox(u::Vect3D, v::Vect3D)
    if v == vect3d(90.0)
        box_type = OrthorombicBox()
    else
        box_type = TriclinicBox()
    end
    return SimBox(u, v, box_type)
end

SimBox(u::Vector, v::Vector) = SimBox(vect3d(u), vect3d(v))
SimBox(u::Vect3D) = SimBox(u, vect3d(90.0))

function SimBox(u::Vector)
    if length(u) == 3
        return SimBox(vect3d(u))
    elseif length(u) == 6
        return SimBox(vect3d(u[1:3]), vect3d(u[4:6]))
    else
        throw(InexactError())
    end
end

SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real) = SimBox(vect3d(Lx, Ly, Lz), vect3d(a, b, c))
SimBox(Lx::Real, Ly::Real, Lz::Real) = SimBox(vect3d(Lx, Ly, Lz))
SimBox(L::Real) = SimBox(L, L, L)
SimBox() = SimBox(0.0)

SimBox(b::SimBox) = b
