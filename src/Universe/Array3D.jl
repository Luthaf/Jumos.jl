#===============================================================================
       Type Array3D: representing arrays of 3D vectors in an efficient way
===============================================================================#
importall Base

export Array3D, Vector3D
export cross, norm, unit!, substract!

immutable SubVector{T, A<:Array} <: AbstractArray{T, 1}
    a::A
    ptr::Ptr{T}
    SubVector(a::A, offset::Int) = new(a, pointer(a, offset+1))
end

getindex(s::SubVector, i::Int) = unsafe_load(s.ptr, i)
setindex!(s::SubVector, v, i::Int) = unsafe_store!(s.ptr, v, i)
size(s::SubVector) = (3,)
length(s::SubVector) = 3

function view{T}(a::Array{T}, ::Colon, j::Int)
    SubVector{T,Array{T}}(a, (j - 1)*3)
end

(+){T}(a::SubVector{T}, b::SubVector{T}) = T[a[1]+b[1], a[2]+b[2], a[3]+b[3]]
(-){T}(a::SubVector{T}, b::SubVector{T}) = T[a[1]-b[1], a[2]-b[2], a[3]-b[3]]


norm(a::SubVector) = sumabs2(a)
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

(==){T}(u::SubVector{T}, v::SubVector{T}) = u.x == v.x && u.y == v.y && u.z == v.z


@doc """
The `Array3D` type store a (3, N) array of floating point numbers.

The size is part of the type, which allow for automatic method checking, *i.e.*
it is impossible to add, substract, … two Array3D with different size.
""" ->
type Array3D{T<:FloatingPoint, N} <: AbstractMatrix{T}
    data::Array{T, 2}
end

function Array3D(Type, N::Integer)
    data = Array(Type, 3, N)
    return Array3D{Type, N}(data)
end

function convert{T}(::Type{Array3D}, data::Array{T, 2})
    i, j = size(data)
    i == 3 || throw(InexactError())
    return Array3D{T, j}(data)
end

function show(io::IO, A::Array3D)
    return show(io, A.data)
end

eltype{T, N}(A::Array3D{T, N}) = T
length{T, N}(A::Array3D{T, N}) = N
ndims(A::Array3D) = 1
size{T, N}(A::Array3D{T, N}) = (3, N)
copy(A::Array3D) = Array3D(copy(A.data))

# Iterator interface
start(A::Array3D) = 1
next(A::Array3D, state::Int) = (A[state], state+1)
done(A::Array3D, state::Int) = length(A) < state

function getindex{T, N}(A::Array3D{T, N}, i::Integer)
    if i > length(A)
        throw(BoundsError())
    end
    return view(A.data, :, i)
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
