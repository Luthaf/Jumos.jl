#===============================================================================
       Type Array3D: representing arrays of 3D vectors in an efficient way
===============================================================================#
importall Base

export Array3D, Vector3D
export cross, norm, normalise

@doc """
The `Array3D` type store a (3, N) array of floating point numbers.

The size is part of the type, which allow for automatic method checking, *i.e.*
it is impossible to add, substract, … two Array3D with different size.
""" ->
type Array3D{T<:FloatingPoint, N} <: DenseArray{T, 2}
    data::Array{T, 2}
end

function Array3D(Type, N::Integer)
    data = Array(Type, 3, N)
    return Array3D{Type, N}(data)
end

function resize!{T, N}(A::Array3D{T, N}, new::Integer)
    return Array3D{T, new}(resize!(A.data, new))
end

function show(io::IO, A::Array3D)
    return show(io, A.data)
end

eltype{T, N}(A::Array3D{T, N}) = T
length{T, N}(A::Array3D{T, N}) = N
ndims(A::Array3D) = 1
size(A::Array3D) = size(A.data)

# Iterator interface
start(A::Array3D) = 1
next(A::Array3D, state::Int) = (A[state], state+1)
done(A::Array3D, state::Int) = length(A) < state

function getindex{T, N}(A::Array3D{T, N}, i::Real)
    if i > length(A)
        error("Out of Bounds. Type: ", typeof(A), " index: ", i)
    end
    return sub(A.data, :, Int(i))
end

# Function for show
getindex{T, N}(A::Array3D{T,N}, i::Real, j::Real) = getindex(A.data, i, j)

function setindex!{T, N}(A::Array3D{T, N}, x, i::Real)
    A.data[:, i] = x
end
setindex!{T, N}(A::Array3D{T,N}, x, i::FloatingPoint, j::Real) = setindex!(A.data, x, i, j)

# Operators
(.+){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D{T, N}(a.data .+ b.data)
(.+){T, N}(a::Array3D{T, N}, b::Real) = Array3D{T, N}(a.data .+ b)
(.+){T, N}(a::Real, b::Array3D{T, N}) = Array3D{T, N}(a .+ b.data)

(.-){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D(a.data .- b.data)
(.-){T, N}(a::Array3D{T, N}, b::Real) = Array3D(a.data .- b)
(.-){T, N}(a::Real, b::Array3D{T, N}) = Array3D(a .- b.data)

(.*){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D{T, N}(a.data .* b.data)
(.*){T, N}(a::Array3D{T, N}, b::Real) = Array3D{T, N}(a.data .* b)
(.*){T, N}(a::Real, b::Array3D{T, N}) = Array3D{T, N}(a .* b.data)

(./){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D(a.data ./ b.data)
(./){T<:FloatingPoint, N}(a::Array3D{T, N}, b::Real) = Array3D{T, N}(a.data ./ b)

(+){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D(a.data + b.data)
(-){T, N}(a::Array3D{T, N}, b::Array3D{T, N}) = Array3D(a.data - b.data)

# Getindex return typealias
typealias Vector3D{T<:Real} SubArray{T, 1, Array{T, 2}, (Colon, Int64), 2}

norm(a::Vector3D) = sqrt(dot(a, a))
cross{T}(u::Vector3D{T}, v::Vector3D{T}) = [u[2]*v[3] - u[3]*v[2],
    u[3]*v[1] - u[1]*v[3],
    u[1]*v[2] - u[2]*v[1]]
normalise{T}(a::Vector3D{T}) = a ./ norm(a)

(==){T}(u::Vector3D{T}, v::Vector3D{T}) = u.x == v.x && u.y == v.y && u.z == v.z
