TEST_DIR = dirname(Base.source_path())

cd(TEST_DIR); cd("../examples")

include("../examples/lennard-jones.jl")

cd(TEST_DIR)
