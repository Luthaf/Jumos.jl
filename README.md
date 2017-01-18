# Jumos is deprecated!

This was a nice experiment, but the Julia language does not appear to be be the right language
to use for this kind of code. I will not maintain this anymore.

Even if it is deprecated, most of the ideas behind Jumos are now part of my new molecular
simulation code: [lumol](https://github.com/lumol-org/lumol).

The code is still available if you want to read it, use it or do whatever you want with it.

---

<div align="center">
    <a href="https://github.com/Luthaf/Jumos.jl">
        <img alt="Jumos Logo" src="https://raw.githubusercontent.com/Luthaf/Jumos.jl/502eee44bcaaf1d782b7628eed062c1de10d0938/doc/_static_/img/logo.png"></img>
    </a>
</div>

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
    <a href="http://pkg.julialang.org/?pkg=Jumos&ver=nightly" >
        <img alt="Pkg evaluation" src="http://pkg.julialang.org/badges/Jumos_nightly.svg"></img>
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
julia> Pkg.add("Jumos")

julia> using Jumos # And then get started by importing the package
```

### Documentation

The [documentation](http://jumos.readthedocs.org) is kindly hosted by ReadTheDocs.
Many thanks to them !

### First run

Their is a *first run* example in the
[documentation](http://jumos.readthedocs.org/en/latest/simulations/usage-example.html),
and some other example scripts in the `example` folder.

## License

All this code brought to you under the terms of the Mozilla Public License v2.0.
The documentation is subject to CC-BY-SA license. By contributing to Jumos, you
agree that your contributions are released under these licenses.
