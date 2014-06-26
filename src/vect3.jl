#===============================================================================
                Type Vect3: immutable type for 3D vectors
===============================================================================#

immutable Vect3{T<:Real}
  x::T
  y::T
  z::T
end

Vect3(x::Real, y::Real, z::Real) = Vect3(promote(x, y, z)...)
Vect3(a::Real) = Vect3(a, a, a)
Vect3(v::Vector) = length(v)==3 ? Vect3(v[1], v[2], v[3]) : throw(InexactError())

convert{T<:Real}(::Type{Vect3}, a::Array{T,1}) = Vect3(a)
convert{S<:Real, T<:Real}(::Type{Vect3{S}}, a::Array{T,1}) = Vect3(a)

function convert{T<:Real}(::Type{Vector{Vect3}}, a::Array{T,2})
    if size(a, 1) == 3
        return Vect3[a[:, i] for i=1:size(a,1)]
    elseif size(a, 2) == 3
        return Vect3[reshape(a[i, :], 3) for i=1:size(a,1)]
    end
    throw(InexactError())
end
# promote_rule

function show(io::IO, v::Vect3)
  print(io, "(", v.x, ", ", v.y, ", ", v.z, ")")
end


(/)(v::Vect3, a::Real) = Vect3(v.x/a, v.y/a, v.z/a)
(*)(v::Vect3, a::Real) = Vect3(v.x*a, v.y*a, v.z*a)
(*)(a::Real, v::Vect3) = Vect3(v.x*a, v.y*a, v.z*a)
(+)(a::Real, v::Vect3) = Vect3(a) + v
(+)(v::Vect3, a::Real) = v + Vect3(a)
(-)(a::Real, v::Vect3) = Vect3(a) - v
(-)(v::Vect3, a::Real) = v - Vect3(a)


(+)(u::Vect3, v::Vect3) = Vect3(u.x + v.x, u.y + v.y, u.z + v.z)
(-)(u::Vect3, v::Vect3) = Vect3(u.x - v.x, u.y - v.y, u.z - v.z)
(.*)(u::Vect3, v::Vect3) = Vect3(u.x * v.x, u.y * v.y, u.z * v.z)
(./)(u::Vect3, v::Vect3) = Vect3(u.x / v.x, u.y / v.y, u.z / v.z)

dot(u::Vect3, v::Vect3) = u.x*v.x + u.y*v.y + u.z*v.z
cross(u::Vect3, v::Vect3) = Vect3(u.y*v.z - u.z*v.y,
                                  u.z*v.x - u.x*v.z,
                                  u.x*v.y - u.y*v.x)

(*)(u::Vect3, v::Vect3) = dot(u, v)
(^)(u::Vect3, v::Vect3) = cross(u, v)

norm(v::Vect3) = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)

function getindex(v::Vect3, i::Integer)
    if i == 1
        return v.x
    elseif i == 2
        return v.y
    elseif i == 3
        return v.z
    end
    throw(BoundsError())
end
