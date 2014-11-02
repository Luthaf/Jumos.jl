#===============================================================================
            Type Vect3D: representing 3D Vectors in an efficient way
===============================================================================#
import Base: norm, show, convert
export Vect3D, vect3d

type Vect3D{T<:Real}
   x::T
   y::T
   z::T
end

function getindex(v::Vect3D, i::Int)
   if i == 1
       return v.x
   elseif i==2
       return v.y
   elseif i==3
       return v.z
   else
       throw(BoundError())
   end
end

typealias RVector{T<:Real} Array{T, 1}
typealias RArray{T<:Real} Array{T, 2}

vect3d{T<:Real}(x::T, y::T, z::T) = Vect3D(x, y, z)
vect3d(x::Real, y::Real, z::Real) = vect3d(promote(x, y, z)...)
vect3d(a::Real) = vect3d(a, a, a)
vect3d(v::RVector) = length(v)==3 ? vect3d(v[1], v[2], v[3]) : throw(InexactError())

convert{T<:Real}(::Type{Vect3D{T}}, v::Vect3D) = vect3d(convert(T, v[1]), convert(T, v[2]), convert(T, v[3]))
convert{T<:Real}(::Type{Vect3D{T}}, v::RVector) = vect3d(v)

function convert{T<:Real}(::Type{Vector{Vect3D{T}}}, a::RArray)
    if size(a, 1) == 3
        return [vect3d(a[:, i]) for i=1:size(a,2)]
    elseif size(a, 2) == 3
        return [vect3d(reshape(a[i, :], 3)) for i=1:size(a,1)]
    end
    throw(InexactError())
end
#TODO: add promote_rule

function show(io::IO, v::Vect3D)
  print(io, "(", v[1], ", ", v[2], ", ", v[3], ")")
end


(/)(v::Vect3D, a::Real) = vect3d(v[1]/a, v[2]/a, v[3]/a)
(*)(v::Vect3D, a::Real) = vect3d(v[1]*a, v[2]*a, v[3]*a)
(*)(a::Real, v::Vect3D) = vect3d(v[1]*a, v[2]*a, v[3]*a)
(+)(a::Real, v::Vect3D) = vect3d(a) + v
(+)(v::Vect3D, a::Real) = v + vect3d(a)
(-)(a::Real, v::Vect3D) = vect3d(a) - v
(-)(v::Vect3D, a::Real) = v - vect3d(a)


(+)(u::Vect3D, v::Vect3D) = vect3d(u[1] + v[1], u[2] + v[2], u[3] + v[3])
(-)(u::Vect3D, v::Vect3D) = vect3d(u[1] - v[1], u[2] - v[2], u[3] - v[3])
(.*)(u::Vect3D, v::Vect3D) = vect3d(u[1] * v[1], u[2] * v[2], u[3] * v[3])
(./)(u::Vect3D, v::Vect3D) = vect3d(u[1] / v[1], u[2] / v[2], u[3] / v[3])

dot(u::Vect3D, v::Vect3D) = u[1]*v[1] + u[2]*v[2] + u[3]*v[3]
cross(u::Vect3D, v::Vect3D) = vect3d(u[2]*v[3] - u[3]*v[2],
                                     u[3]*v[1] - u[1]*v[3],
                                     u[1]*v[2] - u[2]*v[1])

(*)(u::Vect3D, v::Vect3D) = dot(u, v)
(^)(u::Vect3D, v::Vect3D) = cross(u, v)

norm(v::Vect3D) = sqrt(v[1]*v[1] + v[2]*v[2] + v[3]*v[3])

(==)(u::Vect3D, v::Vect3D) = u.x == v.x && u.y == v.y && u.z == v.z
