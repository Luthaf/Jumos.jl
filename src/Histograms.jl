#===============================================================================
        Histograms.jl

        Basic histogram type for various averaging
 ===============================================================================#

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
# Update the histogram weight with the values from v
function update!{T<:Number}(h::Histogram{T}, v::Array{T, 1}; weight=one(T))
    if h.step == 0
        initialize!(h, v)
    end

    for val=v
        bin = ifloor(val/h.step)
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
    for i=1:h.bins
        h.weight[i] /= apply(norm, i)
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
include("dipole.jl")
include("rdf.jl")
