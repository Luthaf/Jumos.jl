# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#      Type Array3D: representing arrays of 3D vectors in an efficient way
# ============================================================================ #

# TODO: remove this and use FixedSize Array when they are disponibles
module Arrays
importall Base

export Array3D
export cross, norm, norm2, unit!, substract!

immutable SubVector{T, A<:Array} <: AbstractArray{T, 1}
    a::A
    ptr::Ptr{T}
    SubVector(a::A, offset::Int) = new(a, pointer(a, offset+1))
end

getindex(s::SubVector, i::Int) = unsafe_load(s.ptr, i)
setindex!(s::SubVector, v, i::Int) = unsafe_store!(s.ptr, v, i)
size(::SubVector) = (3,)
length(::SubVector) = 3
copy(s::SubVector) = [s[1], s[2], s[3]]

function view{T}(a::Array{T}, ::Colon, j::Int)
    SubVector{T,Array{T}}(a, (j - 1)*3)
end

(+){T}(a::SubVector{T}, b::SubVector{T}) = T[a[1]+b[1], a[2]+b[2], a[3]+b[3]]
(-){T}(a::SubVector{T}, b::SubVector{T}) = T[a[1]-b[1], a[2]-b[2], a[3]-b[3]]
# Be carreful: no bounds checking for the Vectors !
(-){T}(a::Vector{T}, b::SubVector{T}) = T[a[1]-b[1], a[2]-b[2], a[3]-b[3]]
(-){T}(a::SubVector{T}, b::Vector{T}) = T[a[1]-b[1], a[2]-b[2], a[3]-b[3]]
(.*){T}(a::SubVector{T}, b::Real) = T[a[1]*b, a[2]*b, a[3]*b]
(.*){T}(a::Real, b::SubVector{T}) = (.*)(b, a)
(./){T}(a::SubVector{T}, b::Real) = T[a[1]/b, a[2]/b, a[3]/b]

norm2(a::SubVector) = a[1]*a[1] + a[2]*a[2] + a[3]*a[3]
dot(a::SubVector) = sqrt(norm2(a))
cross{T}(u::SubVector{T}, v::SubVector{T}) = [u[2]*v[3] - u[3]*v[2],
    u[3]*v[1] - u[1]*v[3],
    u[1]*v[2] - u[2]*v[1]]
function unit!{T}(a::SubVector{T})
    n = norm(a)
    @inbounds begin
        a[1] /= n
        a[2] /= n
        a[3] /= n
    end
    return a
end
function unit!(a::Vector)
    n = norm(a)
    @inbounds begin
        a[1] /= n
        a[2] /= n
        a[3] /= n
    end
    return a
end

# Inplace substraction and addition to remove temporary allocations
function substract!{T}(a::SubVector{T}, b::SubVector{T}, res::Vector)
    res[1] = a[1] - b[1]
    res[2] = a[2] - b[2]
    res[3] = a[3] - b[3]
    return res
end

function add!{T}(a::SubVector{T}, b::SubVector{T}, res::Vector)
    res[1] = a[1] + b[1]
    res[2] = a[2] + b[2]
    res[3] = a[3] + b[3]
    return res
end

(==){T}(u::SubVector{T}, v::SubVector{T}) = u[1] == v[1] && u[2] == v[2] && u[3] == v[3]


@doc """
The `Array3D` type store a (3, N) array of floating point numbers.
""" ->
type Array3D{T<:FloatingPoint} <: AbstractMatrix{T}
    data::Array{T, 2}
end

function Array3D(Type, N::Integer)
    data = Array(Type, 3, N)
    return Array3D{Type}(data)
end

function convert{T}(::Type{Array3D}, data::Array{T, 2})
    i, j = size(data)
    i == 3 || throw(InexactError())
    return Array3D{T}(data)
end

function show(io::IO, A::Array3D)
    return show(io, A.data)
end

eltype{T}(::Array3D{T}) = T
length(A::Array3D) = Int(length(A.data)/3)
ndims(::Array3D) = 1
size(A::Array3D) = size(A.data)
copy(A::Array3D) = Array3D(copy(A.data))

# Iterator interface
start(::Array3D) = 1
next(A::Array3D, state::Int) = (A[state], state+1)
done(A::Array3D, state::Int) = length(A) < state

function getindex{T}(A::Array3D{T}, i::Integer)
    if i > size(A, 2)
        throw(BoundsError())
    end
    return view(A.data, :, i)
end

function resize!{T}(A::Array3D{T}, N::Integer)
    if N > size(A, 1)
        A.data = hcat(A.data, Array(T, 3, N - size(A, 2)))
    elseif N < size(A, 1)
        A.data = copy(A.data[:, 1:N])
    end
    return A
end

function fill!{T}(A::Array3D{T}, val::Real)
    fill!(A.data, val)
end

# Function for show
getindex(A::Array3D, i::Real, j::Real) = getindex(A.data, i, j)

function setindex!(A::Array3D, x, i::Real)
    A.data[:, i] = x
end
setindex!(A::Array3D, x, i::Real, j::Real) = setindex!(A.data, x, i, j)

# Operators
(.+){T}(a::Array3D{T}, b::Array3D{T}) = Array3D{T}(a.data .+ b.data)
(.+){T}(a::Array3D{T}, b::Real) = Array3D{T}(a.data .+ b)
(.+){T}(a::Real, b::Array3D{T}) = Array3D{T}(a .+ b.data)

(.-){T}(a::Array3D{T}, b::Array3D{T}) = Array3D(a.data .- b.data)
(.-){T}(a::Array3D{T}, b::Real) = Array3D(a.data .- b)
(.-){T}(a::Real, b::Array3D{T}) = Array3D(a .- b.data)

(.*){T}(a::Array3D{T}, b::Array3D{T}) = Array3D{T}(a.data .* b.data)
(.*){T}(a::Array3D{T}, b::Real) = Array3D{T}(a.data .* b)
(.*){T}(a::Real, b::Array3D{T}) = Array3D{T}(a .* b.data)

(./){T}(a::Array3D{T}, b::Array3D{T}) = Array3D(a.data ./ b.data)
(./){T<:FloatingPoint}(a::Array3D{T}, b::Real) = Array3D{T}(a.data ./ b)

(+){T}(a::Array3D{T}, b::Array3D{T}) = Array3D(a.data + b.data)
(-){T}(a::Array3D{T}, b::Array3D{T}) = Array3D(a.data - b.data)

end
