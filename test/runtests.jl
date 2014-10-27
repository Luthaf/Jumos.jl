tic()
using Jumos
println("Load time: $(toq())")
using Base.Test

include("vect3d.jl")

include("trajectories.jl")

include("histograms.jl")
