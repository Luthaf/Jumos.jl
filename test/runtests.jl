using Jumos
using FactCheck

TESTS = ["Utils", "Universes", "Simulations"]

function main()
    for test_folder in TESTS
        include(joinpath(test_folder, "tests.jl"))
    end
    FactCheck.exitstatus()
end

const SEP = "   "

function usage()
    println("Select the test you want to run:")
    for (test, help) in tests_available
        println(SEP * string(test) * SEP * help)
    end
    println("Options:")
    println(SEP * "--help (-h): show this help")
end

main()
