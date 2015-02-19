using Jumos
using FactCheck

const tests_available = Dict(
    :distance => "Distances computations",
    :units => "Units conversions",
    :trajectories => "TrajectoriesIO capacities",
    #:analysis => "Trajectories analysis",
    :simulations => "Running MD Simulations"
)

const SEP = "   "

function main()
    tests_selected = Symbol[]
    if length(ARGS) > 0
        for arg in ARGS
            if symbol(arg) in keys(tests_available)
                push!(tests_selected, symbol(arg))
            elseif (arg == "--help") || (arg == "-h")
                usage()
                exit()
            else
                warn("Option $arg not found")
            end
        end
    else
        # Run all tests as default
        tests_selected = keys(tests_available)
    end

    for test in tests_selected
        runtest(test)
    end
    FactCheck.exitstatus()
end

function runtest(test)
    filename = string(test) * ".jl"
    include(filename)
end

function usage()
    println("Select the test you want to run:")
    for (test, help) in tests_available
        println(SEP * string(test) * SEP * help)
    end
    println("Options:")
    println(SEP * "--help (-h): show this help")
end

main()
