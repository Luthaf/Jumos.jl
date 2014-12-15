#===============================================================================
                            Simulation cell type
===============================================================================#
import Base: ==
export UnitCell, InfiniteCell, OrthorombicCell, TriclinicCell
export volume

abstract AbstractCellType
immutable InfiniteCell <: AbstractCellType end
immutable OrthorombicCell <: AbstractCellType end
immutable TriclinicCell <: AbstractCellType end

type UnitCell{T<:AbstractCellType}
    x :: Float64
    y :: Float64
    z :: Float64
    alpha :: Float64
    beta  :: Float64
    gamma :: Float64
end

function getindex(b::UnitCell, i::Int)
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

function ==(a::UnitCell, b::UnitCell)
    return a.x == b.x && a.y == b.y && a.z == b.z && a.alpha == b.alpha && a.beta == b.beta && a.gamma == b.gamma
end


#==============================================================================#
# Automatic cell type

function UnitCell(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)
    if a == pi/2 && b == pi/2 && c == pi/2
        cell_type = OrthorombicCell
    else
        cell_type = TriclinicCell
    end
    return UnitCell{cell_type}(Lx, Ly, Lz, a, b, c)
end

UnitCell(Lx::Real, Ly::Real, Lz::Real) = UnitCell(Lx, Ly, Lz, pi/2, pi/2, pi/2)

function UnitCell(u::Vector)
    if length(u) == 3 || length(u) == 6
        return UnitCell(u...)
    else
        throw(InexactError())
    end
end

function UnitCell(u::Vector, v::Vector)
    if length(u) == 3 && length(v) == 3
        return UnitCell(u..., v...)
    else
        throw(InexactError())
    end
end

UnitCell(L::Real) = UnitCell(L, L, L)
UnitCell() = UnitCell(0.0)

UnitCell(b::UnitCell) = b

#==============================================================================#
# Manual cell type
UnitCell{T<:Type{AbstractCellType}}(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real, celltype::T) = UnitCell{celltype}(Lx, Ly, Lz, a, b, c)

UnitCell{T<:Type{AbstractCellType}}(Lx::Real, Ly::Real, Lz::Real, celltype::T) = UnitCell(Lx, Ly, Lz, pi/2, pi/2, pi/2, celltype)

function UnitCell{T<:Type{AbstractCellType}}(u::Vector, celltype::T)
    if length(u) == 3 || length(u) == 6
        return UnitCell(u..., celltype)
    else
        throw(InexactError())
    end
end

function UnitCell{T<:Type{AbstractCellType}}(u::Vector, v::Vector, celltype::T)
    if length(u) == 3 && length(v) == 3
        return UnitCell(u..., v..., celltype)
    else
        throw(InexactError())
    end
end

UnitCell{T<:Type{AbstractCellType}}(L::Real, celltype::T) = UnitCell(L, L, L, celltype)
UnitCell{T<:Type{AbstractCellType}}(celltype::T) = UnitCell(0.0, celltype)

#==============================================================================#
function volume(::UnitCell)
    return 0.0
end

function volume(cell::UnitCell{OrthorombicCell})
    return cell.x * cell.y * cell.z
end

function volume(cell::UnitCell{TriclinicCell})
    α = cell.alpha
    β = cell.beta
    γ = cell.gamma

    Vol = cell.x * sin(γ) * cell.y
    tmp = sqrt(1 - cos(β)^2 - ((cos(α) - cos(β)*cos(γ))/sin(α))^2)
    return Vol * tmp * cell.z
end
