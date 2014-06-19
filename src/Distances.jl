#===============================================================================
                    Distance computing utilities
===============================================================================#

# Refine a vector using the minimal image convention
function minimal_image!{T<:Number}(vect::Array{T, 1}, box::Box)
    vect[1] -= round(vect[1]/box[1])*box[1]
    vect[2] -= round(vect[2]/box[2])*box[2]
    vect[3] -= round(vect[3]/box[3])*box[3]
    return None
end

function pbc_distance(s::Frame, i::Integer, j::Integer)
    xx = s.positions[1, i] - s.positions[1, j]
    yy = s.positions[2, i] - s.positions[2, j]
    zz = s.positions[3, i] - s.positions[3, j]
	# Periodic boundary conditions
	xx -= round(xx / s.box[1]) * s.box[1]
	yy -= round(yy / s.box[2]) * s.box[2]
	zz -= round(zz / s.box[3]) * s.box[3]
    return sqrt(xx*xx + yy*yy + zz*zz)
end

function distance(s::Frame, i::Integer, j::Integer)
    xx = s.positions[1, i] - s.positions[1, j]
    yy = s.positions[2, i] - s.positions[2, j]
    zz = s.positions[3, i] - s.positions[3, j]
    return sqrt(xx*xx + yy*yy + zz*zz)
end
