#===============================================================================
                    Distance computing utilities
===============================================================================#

export distance, distance_array, distance3d, minimal_image, minimal_image!

@doc "
`minimal_image(vect::Vect3D, box::SimBox)`

Refine a vector using the minimal image convention
" ->
minimal_image(vect::AbstractVector, box::SimBox{InfiniteBox}) = vect
minimal_image!(vect::AbstractVector, box::SimBox{InfiniteBox}) = vect

function minimal_image(vect, box::SimBox)
    tmp = copy(vect)
    return minimal_image!(tmp, box)
end

function minimal_image!(vect::AbstractVector, box::SimBox{OrthorombicBox})
    vect[1] -= floor(vect[1]/box.x)*box.x
    vect[2] -= floor(vect[2]/box.y)*box.y
    vect[3] -= floor(vect[3]/box.z)*box.z
    return vect
end

function minimal_image!(vect::AbstractVector, box::SimBox{TriclinicBox})
    cart2fract!(vect, box)
    vect[1] -= round(vect[1])
    vect[2] -= round(vect[2])
    vect[3] -= round(vect[3])
    return fract2cart!(vect, box)
end

function minimal_image!(a::Array3D, box::SimBox)
    @inbounds for i=1:length(a)
        minimal_image!(a[i], box)
    end
end

function minimal_image!(a::Matrix, box::SimBox)
    cols, rows = size(a)
    cols == 3 || error("Wrong size for matrix a. Should be (3, N)")
    @inbounds for i=rows
        minimal_image!(a[:, i], box)
    end
end

function cart2fract!(vect::AbstractVector, box::SimBox)
    const z = vect[3]/box.gamma
    const y = (vect[2] - z*box.beta)/box.z
    const x = (vect[1] - z*box.alpha - y * box.y) / box[1]

    vect[1] = x
    vect[2] = y
    vect[3] = z

    return vect
end

function cart2fract(vect::AbstractVector, box::SimBox)
    tmp = copy(vect)
    return cart2fract!(tmp, box)
end

function fract2cart!(vect::AbstractVector, box::SimBox)
    vect[1] = vect[1]*box[1] + vect[2]*box.y + vect[3]*box.alpha
    vect[2] = vect[2]*box.z + vect[3]*box.beta
    vect[3] = vect[3]*box.gamma
    return vect
end

function cart2fract(vect::AbstractVector, box::SimBox)
    tmp = copy(vect)
    return cart2fract!(tmp, box)
end

function fract2cart!(vect::AbstractVector, box::SimBox)
    vect[1] = vect[1]*box[1] + vect[2]*box.y + vect[3]*box.alpha
    vect[2] = vect[2]*box.z + vect[3]*box.beta
    vect[3] = vect[3]*box.gamma
    return vect
end

@doc "
`distance(ref::Frame, conf::Frame, i::Integer, j::Integer)`

Compute the distance between to particles, using the minimal image conventions.

i and j are particle index, the computed distance is ref[j] - conf[i]
" ->
function distance(ref::Frame, conf::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return norm(minimal_image!(substract!(ref.positions[j], conf.positions[i], work), ref.box))
end

@doc "
`distance(ref::Frame, conf::Frame, i::Integer)`

Compute the distance between the same particle in two frames
" ->
function distance(ref::Frame, conf::Frame, i::Integer)
    return distance(ref, ref, i, i)
end

@doc "
`distance(ref::Frame, i::Integer, j::Integer)`

Compute the distance between two particles in the same frame
" ->
function distance(ref::Frame, i::Integer, j::Integer)
    return distance(ref, ref, i, j)
end

@doc "
`distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer)`

Compute the vector between two particles in two frames.
i and j are particle index, the computed distance is ref[j] - conf[i]
" ->
function distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return minimal_image!(substract!(ref.positions[j], conf.positions[i], work), ref.box)
end

@doc "
`distance3d(ref::Frame, i::Integer, j::Integer)`

Compute the vector between the two particle in the same frame.
" ->
function distance3d(ref::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return distance3d(ref, conf, i, i, work)
end

@doc "
`distance3d(ref::Frame, conf::Frame, i::Integer)`

Compute the vector between the same particle in the two frames.
" ->
function distance3d(ref::Frame, conf::Frame, i::Integer, work=[0., 0., 0.])
    return distance3d(ref, conf, i, i, work)
end


@doc "
`distance3d(ref::Frame, i::Integer, j::Integer)`

Compute the vector between two particles in the same frame.
" ->
function distance3d(ref::Frame, i::Integer, j::Integer)
    return distance3d(ref, ref, i, j)
end


@doc "
`distance_array(ref::Frame, conf::Frame, result = nothing)`

Compute all the distances between particles in the same frame.
Result can be a pre-allocated array for result storage. After the function,
    result[i, j] = distance(ref, i, j)
" ->
function distance_array(ref::Frame, result = nothing)
    return distance_array(ref, ref, result)
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
                    "should be ($(cols),$(rows))\n" *
                    "Resizing ...")
            resize!(result, (cols, rows))
        end
    end
    compute_distance_array!(result, ref, conf, rows, cols)
    return result
end

using Distances

function compute_distance_array!(result, ref, conf, nrows, ncols)
    ref_tmp = copy(ref.positions.data)
    conf_tmp = copy(conf.positions.data)
    minimal_image!(ref_tmp, ref.box)
    minimal_image!(conf_tmp, conf.box)

    pairwise!(result, Euclidean(), ref_tmp, conf_tmp)
    return result
end
