TEST_DIR = dirname(@__FILE__)

cd(TEST_DIR); cd("../examples")

include("../examples/lennard-jones.jl")

cd(TEST_DIR)
