using Jumos
using FactCheck

TESTS = ["Utils", "Universes", "Simulations"]

function main()
    for test_folder in TESTS
        include(joinpath(test_folder, "tests.jl"))
    end
    FactCheck.exitstatus()
end

main()
