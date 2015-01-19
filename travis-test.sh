#!/bin/bash
set -ev

git fetch --unshallow
julia -e 'Pkg.clone(pwd())'
julia -e 'Pkg.add("FactCheck")'

if [ -f test/runtests.jl ]; then
    julia --check-bounds=yes -e 'Pkg.test("Jumos", coverage=true)'
fi

