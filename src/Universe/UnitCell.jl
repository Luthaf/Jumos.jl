#===============================================================================
                            Simulation cell type
===============================================================================#

export UnitCell, InfiniteCell, OrthorombicCell, TriclinicCell

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


#==============================================================================#
# Automatic cell type

function UnitCell(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)
    if a == 90.0 && b == 90.0 && c == 90.0
        cell_type = OrthorombicCell
    else
        cell_type = TriclinicCell
    end
    return UnitCell{cell_type}(Lx, Ly, Lz, a, b, c)
end

UnitCell(Lx::Real, Ly::Real, Lz::Real) = UnitCell(Lx, Ly, Lz, 90., 90., 90.)

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
UnitCell(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real, celltype::Type{AbstractCellType}) = UnitCell{celltype}(Lx, Ly, Lz, a, b, c)
UnitCell(Lx::Real, Ly::Real, Lz::Real, celltype::Type{AbstractCellType}) = UnitCell(Lx, Ly, Lz, 90., 90., 90., celltype)

function UnitCell(u::Vector, celltype::Type{AbstractCellType})
    if length(u) == 3 || length(u) == 6
        return UnitCell(u..., celltype)
    else
        throw(InexactError())
    end
end

function UnitCell(u::Vector, v::Vector, celltype::Type{AbstractCellType})
    if length(u) == 3 && length(v) == 3
        return UnitCell(u..., v..., celltype)
    else
        throw(InexactError())
    end
end

UnitCell(L::Real, celltype::Type{AbstractCellType}) = UnitCell(L, L, L, celltype)
UnitCell(celltype::Type{AbstractCellType}) = UnitCell(0.0, celltype)
