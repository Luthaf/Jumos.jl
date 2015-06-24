# Copyright (c) Guillaume Fraux 2014-2015
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

@doc doc"
`minimal_image(vector, unit_cell)`

Refine a vector using the minimal image convention
" -> minimal_image

@doc doc"
`minimal_image!(vector, unit_cell)`

Refine a vector in-place using the minimal image convention
" -> minimal_image!

function minimal_image(vect, cell::UnitCell)
    tmp = copy(vect)
    return minimal_image!(tmp, cell)
end

function minimal_image!(vect::AbstractVector, cell::UnitCell{OrthorombicCell})
    vect[1] = vect[1] - round(vect[1]/cell.a)*cell.a
    vect[2] = vect[2] - round(vect[2]/cell.b)*cell.b
    vect[3] = vect[3] - round(vect[3]/cell.c)*cell.c
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

@doc doc"
`distance(universe, i, j [,work] )`

Compute the distance between the particles `i` and `j` in the `universe`. `work`
can be a pre-allocated vector of Float64 with 3 components.
" ->
function distance(universe::Universe, i::Integer, j::Integer, work=[0., 0., 0.])
    return norm(
            minimal_image!(
                    substract!(
                        universe.frame.positions[i],
                        universe.frame.positions[j],
                        work),
                    universe.cell)
                )
end


@doc doc"
`distance3d(universe, i, j [,work] )`

Compute the vector between two particles in the universe. The distance computed
is `positions[j] - positions[i]`. `work` can be a pre-allocated vector of
Float64 with 3 components.
" ->
function distance3d(universe::Universe, i::Integer, j::Integer, work=[0., 0., 0.])
    return minimal_image!(substract!(universe.frame.positions[j],
                                     universe.frame.positions[i],
                                     work),
                          universe.cell)
end

@doc doc"
`distance_array(universe [, result])`

Compute all the distances between particles in the universe. `result` can be a
pre-allocated array for the distances storage. After the function, `result[i, j]
= distance(universe, i, j)`
" ->
function distance_array(universe::Universe, result = nothing)
    cols = length(universe.frame.positions)
    # Checking the pre-allocated array
    if result == nothing
        result = Array(Float64, cols, cols)
    else
        _check_result_size(result, cols, cols)
    end
    compute_distance_array!(result, universe)
    return result
end

import Distances

function compute_distance_array!(result, universe)
    tmp = copy(universe.frame.positions.data)
    minimal_image!(tmp, universe.cell)

    Distances.pairwise!(result, Distances.Euclidean(), tmp)
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
