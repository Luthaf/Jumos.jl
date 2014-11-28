#===============================================================================
                            Simulation box type
===============================================================================#

export SimBox, InfiniteBox, OrthorombicBox, TriclinicBox

abstract AbstractBoxType
type InfiniteBox <: AbstractBoxType end
type OrthorombicBox <: AbstractBoxType end
type TriclinicBox <: AbstractBoxType end

type SimBox{T<:AbstractBoxType}
    x :: Float64
    y :: Float64
    z :: Float64
    alpha :: Float64
    beta  :: Float64
    gamma :: Float64
    box_type :: T
end

function getindex(b::SimBox, i::Int)
    if i == 1
        return b.x
    elseif i == 2
        return b.y
    elseif i == 3
        return b.z
    elseif i == 4
        return b.alpha
    elseif i == 5
        return b.beta
    elseif i == 6
        return b.gamma
    end
    throw(BoundsError())
end


#==============================================================================#
# Automatic box type

function SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)
    if a == 90.0 && b == 90.0 && c == 90.0
        box_type = OrthorombicBox()
    else
        box_type = TriclinicBox()
    end
    return SimBox(Lx, Ly, Lz, a, b, c, box_type)
end

SimBox(Lx::Real, Ly::Real, Lz::Real) = SimBox(Lx, Ly, Lz, 90., 90., 90.)

function SimBox(u::Vector)
    if length(u) == 3 || length(u) == 6
        return SimBox(u...)
    else
        throw(InexactError())
    end
end


SimBox(L::Real) = SimBox(L, L, L)
SimBox() = SimBox(0.0)

SimBox(b::SimBox) = b

#==============================================================================#
# Manual box type

SimBox(Lx::Real, Ly::Real, Lz::Real, btype::AbstractBoxType) = SimBox(Lx, Ly, Lz, 90., 90., 90., btype)

function SimBox(u::Vector, btype::AbstractBoxType)
    if length(u) == 3 || length(u) == 6
        return SimBox(u..., btype)
    else
        throw(InexactError())
    end
end

SimBox(L::Real, btype::AbstractBoxType) = SimBox(L, L, L, btype)
SimBox(btype::AbstractBoxType) = SimBox(0.0, btype)
