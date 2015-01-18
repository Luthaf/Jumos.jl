Welcome to Jumos's documentation!
=================================

`Jumos` is a package for molecular simulations using the
`Julia <http://julialang.org/>`_ language. It aims at being as flexible as
possible, and to to allows the easy use and development of novel algorithm for
each part of a simulation. Every algorithm, from potential computation, long
range interactions, pair lists computing, outputs, `etc.` can be customised.

Jumos also includes code for trajectory analysis, either during the simulation
run or by reading frames in a file.

.. warning::
    This package is in a very alpha stage, and still in heavy developement.
    Breaking changes can occurs in the API without any notice at any time.

Jumos is composed of 7 main modules : `Units`, `Universe`, `Atoms`, `Simulations`,
`Trajectories`, `PBC` and `Analysis`.

If you want to start running simulations directly go to the :ref:`simulation-usage`.
You can also explore the sub-packages with the links below.

.. toctree::
    :maxdepth: 2

    units
    universe
    distances
    atoms
    simulations/index
    trajectories
    analysis/index

Installation
------------

To install, simply run ``Pkg.clone(https://github.com/Luthaf/Jumos.jl)`` at
julia prompt. You may also want to run ``Pkg.test("Jumos")`` to run the tests.

Only 0.4 julia prerelease version is supported, because `Jumos` makes use of
features from the 0.4 version.
