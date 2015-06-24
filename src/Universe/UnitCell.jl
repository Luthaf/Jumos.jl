# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                          Simulation cell type
# ============================================================================ #

export UnitCell, InfiniteCell, OrthorombicCell, TriclinicCell
export volume, cellmatrix

abstract AbstractCellType
immutable InfiniteCell <: AbstractCellType end
immutable OrthorombicCell <: AbstractCellType end
immutable TriclinicCell <: AbstractCellType end

type UnitCell{T<:AbstractCellType}
    a :: Float64
    b :: Float64
    c :: Float64
    alpha :: Float64
    beta  :: Float64
    gamma :: Float64
end

function Base.show(io::IO, cell::UnitCell)
    ctype = split(string(celltype(cell)), ".")[end]
    print(io, ctype)
    if !(celltype(cell) == InfiniteCell)
        print(io, "\n   Lenghts: ", cell.a, ", ", cell.b, ", ", cell.c)
        if celltype(cell) == TriclinicCell
            print(io, "\n   Angles: ", cell.alpha, ", ", cell.beta, ", ", cell.gamma)
        end
    end
end

celltype{T<:AbstractCellType}(::UnitCell{T}) = T

function getindex(b::UnitCell, i::Int)
    if i == 1
        return b.a
    elseif i == 2
        return b.b
    elseif i == 3
        return b.c
    elseif i == 4
        return b.alpha
    elseif i == 5
        return b.beta
    elseif i == 6
        return b.gamma
    end
    throw(BoundsError())
end

function (==)(a::UnitCell, b::UnitCell)
    return a.a == b.a && a.b == b.b && a.c == b.c &&
           a.alpha == b.alpha && a.beta == b.beta && a.gamma == b.gamma
end

#==============================================================================#

function UnitCell(a, b, c, alpha, beta, gamma)
    if alpha == pi/2 && beta == pi/2 && gamma == pi/2
        cell_type = OrthorombicCell
    else
        cell_type = TriclinicCell
    end
    return UnitCell{cell_type}(a, b, c, alpha, beta, gamma)
end

UnitCell(a, b, c) = UnitCell(a, b, c, pi/2, pi/2, pi/2)

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

UnitCell{T<:Type{AbstractCellType}}(a, b, c, alpha, beta, gamma, celltype::T) =
    UnitCell{celltype}(a, b, c, alpha, beta, gamma)

UnitCell{T<:Type{AbstractCellType}}(a, b, c, celltype::T) =
    UnitCell(a, b, c, pi/2, pi/2, pi/2, celltype)

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

function volume(::UnitCell{InfiniteCell})
    return 0.0
end

function volume(cell::UnitCell{OrthorombicCell})
    return cell.a * cell.b * cell.c
end

function volume(cell::UnitCell{TriclinicCell})
    α = cell.alpha
    β = cell.beta
    γ = cell.gamma

    V = cell.a * cell.b * cell.c
    factor = sqrt(1 - cos(α)^2 - cos(β)^2 - cos(γ)^2 + 2*cos(α)*cos(β)*cos(γ))
    return V * factor
end

#==============================================================================#

function cellmatrix(c::UnitCell)
    res = zeros(Float64, 3, 3)

    res[1,1] = c.a

    res[2,1] = c.b * cos(c.gamma)
    res[2,2] = c.b * sin(c.gamma)

    res[3,1] = c.c * ((cos(c.alpha) - 1)*cos(c.beta))/(cos(c.beta)*cos(c.gamma) - 1)
    res[3,1] += c.c * cos(c.gamma) * (cos(c.beta)*cos(c.gamma)
                        - cos(c.alpha)) / (cos(c.beta)*cos(c.gamma) - 1)

    res[3,2] = c.c * sin(c.gamma) * (cos(c.beta)*cos(c.gamma)
                        - cos(c.alpha)) / (cos(c.beta)*cos(c.gamma) - 1)

    res[3,3] = c.c * ((cos(c.alpha)-1)*(cos(c.beta)+ cos(c.gamma))*cos(c.gamma)
                          + sin(c.alpha)^2) / (1 - cos(c.gamma)cos(c.beta))
    return res
end
