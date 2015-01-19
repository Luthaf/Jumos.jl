# Jumos

<div align="center">
    <a href="https://travis-ci.org/Luthaf/Jumos.jl" >
        <img alt="Build Status" src="https://travis-ci.org/Luthaf/Jumos.jl.svg?branch=master"></img>
    </a>
    <a href="https://coveralls.io/r/Luthaf/Jumos.jl" >
        <img alt="Coverage Status" src="https://img.shields.io/coveralls/Luthaf/Jumos.jl.svg"></img>
    </a>
    <a href="http://jumos.readthedocs.org/en/latest/" >
        <img alt="Documentation Status" src="https://readthedocs.org/projects/jumos/badge/?version=latest"></img>
    </a>
</div>

Jumos is a Julia package for molecular simulation and analysis. This package is
still in a very alpha stage of development, and even if it might already be used
for simple simulations, it have NOT been tested in all the possibles cases.
Moreover, the API can change at any time without any notice.

This package aims at being as extensible as possible. Every algorithm can be
replaced and selected for each step. More than that, you can easily write new
algorithms, and experiment with them.

## Features

- Use your own potentials simply by providing a function;
- Develop new algorithms for molecular dynamic with ease;
- Run dynamic molecular dynamic from the REPL;
- Perform basic analysis of the run, and write your own analysis tools;
- Read and analyse trajectories from previous run.

## Getting started

### Installation

Jumos needs the nighlty version (0.4) of Julia. Then, enter the following at the
REPL:
```jlcon
julia> Pkg.add("https://github.com/Luthaf/Jumos.jl")

# And get started by importing the package
julia> using Jumos
```

### First run

Their is a *first run* example in the
[documentation](http://jumos.readthedocs.org/en/latest/simulations/usage-example.html),
and some other example scripts in the `example` folder.

## Licence

All this code brought to you under the termes of the Mozilla Public Licence v2.0.
