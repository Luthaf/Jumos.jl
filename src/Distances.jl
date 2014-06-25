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

function pbc_distance(ref::Frame, conf::Frame, i, j)
    xx = ref.positions[1, i] - conf.positions[1, j]
    yy = ref.positions[2, i] - conf.positions[2, j]
    zz = ref.positions[3, i] - conf.positions[3, j]
	# Periodic boundary conditions
	xx -= round(xx / ref.box[1]) * ref.box[1]
	yy -= round(yy / ref.box[2]) * ref.box[2]
	zz -= round(zz / ref.box[3]) * ref.box[3]
    return sqrt(xx*xx + yy*yy + zz*zz)
end

function distance(ref::Frame, conf::Frame, i, j)
    xx = ref.positions[1, i] - conf.positions[1, j]
    yy = ref.positions[2, i] - conf.positions[2, j]
    zz = ref.positions[3, i] - conf.positions[3, j]
    return sqrt(xx*xx + yy*yy + zz*zz)
end

function distance_array(ref::Frame, conf::Frame, result = nothing)
    cols = ref.trajectory.natoms
    rows = conf.trajectory.natoms
    # Checking the pre-allocated array
    if result == nothing
        result = Array(Float64, cols, rows)
    else
        if !((size(result, 1) == cols) && (size(result, 2) == rows))
            warning("Wrong pre-allocated array shape. Is $(size(result)), " *
                    "should be ($(cols),$(rows))")
        end
    end

    has_box = ref.box[1] != 0 && ref.box[2] != 0 && ref.box[3] != 0

    for i=1:cols
        for j=1:rows
            if has_box
                result[i,j] = pbc_distance(ref, conf, i, j)
            else
                result[i,j] = distance(ref, conf, i, j)
            end
        end
    end

    return result
end

