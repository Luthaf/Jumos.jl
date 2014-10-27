#===============================================================================
                    Distance computing utilities
===============================================================================#

# Refine a vector using the minimal image convention
@inline minimal_image(vect::Vect3D, box::SimBox{InifiniteBox}) = vect

@inline function minimal_image(vect::Vect3D, box::SimBox{OrthorombicBox})
    return vect3d(
        vect[1] - round(vect[1]/box[1])*box[1],
        vect[2] - round(vect[2]/box[2])*box[2],
        vect[3] - round(vect[3]/box[3])*box[3]
    )
end

@inline function minimal_image(vect::Vect3D, box::SimBox{TriclinicBox})
    u = cart2fract(vect, box)
    return fract2cart(vect3d(
                         u[1] - round(u[1]),
                         u[2] - round(u[2]),
                         u[3] - round(u[3])),
                      box)
end

@inline function cart2fract(vect::Vect3D, box::SimBox)
    const z = vect[3]/box[6]
    const y = (vect[2] - z*box[5])/box[3]
    const x = (vect[1] - z*box[4] - y * box[2]) / box[1]

    return vect3d(x, y, z)
end

@inline function fract2cart(vect::Vect3D, box::SimBox)
    return vect3d(
        vect[1]*box[1] + vect[2]*box[2] + vect[3]*box[4],
        vect[2]*box[3] + vect[3]*box[5],
        vect[3]*box[6]
    )
end


@inline function distance(ref::Frame, conf::Frame, i, j)
    return norm(minimal_image(ref.positions[i] - conf.positions[j], ref.box))
end

function distance_array(ref::Frame, conf::Frame, result = nothing)
    cols = length(ref.positions)
    rows = length(conf.positions)
    # Checking the pre-allocated array
    if result == nothing
        result = Array(Float64, cols, rows)
    else
        if !((size(result, 1) == cols) && (size(result, 2) == rows))
            warning("Wrong pre-allocated array shape. Is $(size(result)), " *
                    "should be ($(cols),$(rows))")
        end
    end
    compute_distance_array!(result, ref, conf, rows, cols)
    return result
end

function compute_distance_array!(result, ref, conf, nrows, ncols)
    for j=1:nrows, i=1:ncols
       result[i,j] = distance(ref, conf, i, j)
    end
end
