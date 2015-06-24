# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                Basic histogram type for time averaging
# ============================================================================ #

export Histogram
export update!, normalize!, write, clean!

type Histogram{T<:Number}
    bins::Int
    weight::Array{T, 1}
    min::Number
    max::Number
    step::Number
    used::Int
end

function Histogram(T::DataType, bins::Integer;
                   min=0, max=0, step=0)
    if bins == 0
        error("Can not create an histogram with 0 bins")
    end
    weight = zeros(T, bins)
    return Histogram(bins, weight, min, max, step, 0)
end

#==============================================================================#
# Update the histogram weight
function update!{T<:Number}(h::Histogram{T}, values::Array{T, 1}; weight=one(T))
    if h.step == 0
        initialize!(h, values)
    end

    @inbounds for val in values
        bin = floor(Int64, val/h.step)
        if 0 < bin <= h.bins
            h.weight[bin] += weight
            h.used += 1
        end
    end
    return nothing
end

#==============================================================================#
# Initialize the histogram step
function initialize!{T<:Number}(h::Histogram{T}, v::Array{T, 1})
    if h.min != h.max
        h.step = (h.max - h.min)/h.bins
    else
        # Let's take the max and min values from v
        h.min = minimum(v)
        h.max = maximum(v)
        h.step = (h.max - h.min)/h.bins
    end
    if h.step == 0
        error("Histogram step can not be zero")
    end
    return nothing
end

#==============================================================================#
# normalize by a constant
function normalize!{T<:Number}(h::Histogram{T}, norm::T)
    h.weight ./= norm
    return nothing
end

# normalize by a function of the current bin
function normalize!{T<:Number}(h::Histogram{T}, norm::Function)
    @inbounds for i=1:h.bins
        h.weight[i] /= norm(i)
    end
    return nothing
end

#==============================================================================#
# clean weights
function clean!{T<:Number}(h::Histogram{T})
    h.weight = zeros(T, h.bins)
    h.used = 0
    return nothing
end

#==============================================================================#
# Includes
include("density.jl")
include("rdf.jl")
