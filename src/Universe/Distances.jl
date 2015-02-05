# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                      Distance computing using PBC
# ============================================================================ #

export distance, distance_array, distance3d, minimal_image, minimal_image!

minimal_image(vect::AbstractVector, ::UnitCell{InfiniteCell}) = vect
minimal_image!(vect::AbstractVector, ::UnitCell{InfiniteCell}) = vect

@doc "
`minimal_image(vect::AbstractVector, cell::UnitCell)`

Refine a vector using the minimal image convention
" -> minimal_image

@doc "
`minimal_image!(vect::AbstractVector, cell::UnitCell)`

Refine a vector in-place using the minimal image convention
" -> minimal_image!

function minimal_image(vect, cell::UnitCell)
    tmp = copy(vect)
    return minimal_image!(tmp, cell)
end

function minimal_image!(vect::AbstractVector, cell::UnitCell{OrthorombicCell})
    vect[1] = vect[1] - round(vect[1]/cell.x)*cell.x
    vect[2] = vect[2] - round(vect[2]/cell.y)*cell.y
    vect[3] = vect[3] - round(vect[3]/cell.z)*cell.z
    return vect
end

function minimal_image!(vect::AbstractVector, cell::UnitCell{TriclinicCell})
    realvects = cellmatrix(cell::UnitCell)
    for i in [3, 2, 1]
        while abs(vect[i]) > realvects[i,i]/2
            if vect[i] < 0
                vect[1] += realvects[i, 1]
                vect[2] += realvects[i, 2]
                vect[3] += realvects[i, 3]
            else
                vect[1] -= realvects[i, 1]
                vect[2] -= realvects[i, 2]
                vect[3] -= realvects[i, 3]
            end
        end
    end
    return vect
end

function minimal_image!(a::Array3D, cell::UnitCell)
    @inbounds for i=1:length(a)
        minimal_image!(a[i], cell)
    end
end

function minimal_image!(a::Matrix, cell::UnitCell)
    cols, rows = size(a)
    cols == 3 || error("Wrong size for matrix a. Should be (3, N)")
    @inbounds for i=rows
        minimal_image!(a[:, i], cell)
    end
end


function cellmatrix(cell::UnitCell)
    res = zeros(Float64, 3, 3)

    res[1,1] = cell.x

    res[2,1] = cell.y * cos(cell.gamma)
    res[2,2] = cell.y * sin(cell.gamma)

    res[3,1] = cell.z * ((cos(cell.alpha) - 1)*cos(cell.beta))/(cos(cell.beta)*cos(cell.gamma) - 1)
    res[3,1] += cell.z * cos(cell.gamma) * (cos(cell.beta)*cos(cell.gamma)
                        - cos(cell.alpha)) / (cos(cell.beta)*cos(cell.gamma) - 1)

    res[3,2] = cell.z * sin(cell.gamma) * (cos(cell.beta)*cos(cell.gamma)
                        - cos(cell.alpha)) / (cos(cell.beta)*cos(cell.gamma) - 1)

    res[3,3] = cell.z * ((cos(cell.alpha)-1)*(cos(cell.beta)+ cos(cell.gamma))*cos(cell.gamma)
                          + sin(cell.alpha)^2) / (1 - cos(cell.gamma)cos(cell.beta))
    return res
end

# @doc "
# `distance(ref::Frame, conf::Frame, i::Integer, j::Integer)`
#
# Compute the distance between to particles, using the minimal image conventions.
#
# i and j are particle index, the computed distance is ref[j] - conf[i]
# " ->
function distance(ref::Frame, conf::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return norm(minimal_image!(substract!(ref.positions[j], conf.positions[i], work), ref.cell))
end

@doc "
`distance(ref::Frame, conf::Frame, i::Integer)`

Compute the distance between the same particle in two frames
" ->
function distance(ref::Frame, conf::Frame, i::Integer)
    return distance(ref, conf, i, i)
end

@doc "
`distance(ref::Frame, i::Integer, j::Integer)`

Compute the distance between two particles in the same frame
" ->
function distance(ref::Frame, i::Integer, j::Integer)
    return distance(ref, ref, i, j)
end

# @doc "
# `distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer)`

# Compute the vector between two particles in two frames.
# i and j are particle index, the computed distance is ref[j] - conf[i]
# " ->
function distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return minimal_image!(substract!(ref.positions[j], conf.positions[i], work), ref.cell)
end

@doc "
`distance3d(ref::Frame, i::Integer, j::Integer)`

Compute the vector between the two particle in the same frame.
" ->
function distance3d(ref::Frame, i::Integer, j::Integer, work=[0., 0., 0.])
    return distance3d(ref, ref, i, j, work)
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
function distance_array(ref::Frame, conf::Frame, result = [])
    cols = length(ref.positions)
    rows = length(conf.positions)
    # Checking the pre-allocated array
    if result == []
        result = Array(Float64, cols, rows)
    else
        _check_result_size(result, cols, rows)
    end
    compute_distance_array!(result, ref, conf)
    return result
end

function distance_array(ref::Frame, result = [])
    cols = length(ref.positions)
    # Checking the pre-allocated array
    if result == []
        result = Array(Float64, cols, cols)
    else
        _check_result_size(result, cols, cols)
    end
    compute_distance_array!(result, ref)
    return result
end

using Distances

function compute_distance_array!(result, ref, conf)
    ref_tmp = copy(ref.positions.data)
    conf_tmp = copy(conf.positions.data)
    minimal_image!(ref_tmp, ref.cell)
    minimal_image!(conf_tmp, conf.cell)

    pairwise!(result, Euclidean(), ref_tmp, conf_tmp)
    return result
end

function compute_distance_array!(result, ref)
    ref_tmp = copy(ref.positions.data)
    minimal_image!(ref_tmp, ref.cell)

    pairwise!(result, Euclidean(), ref_tmp)
    return result
end

function _check_result_size(result, cols, rows)
    if !((size(result, 1) == cols) && (size(result, 2) == rows))
        warning("Wrong pre-allocated array shape. Is $(size(result)), " *
        "should be ($(cols),$(rows))\n" *
        "Resizing ...")
        resize!(result, (cols, rows))
    end
end
