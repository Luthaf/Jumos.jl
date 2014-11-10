.. Jumos documentation master file

Welcome to Jumos's documentation!
=================================

`Jumos` is a package for molecular simulations using the
`Julia <http://julialang.org/>`_ language. Its goal is to be as flexible as
possible, and to make it easy to use and develop novel algorithm for each part
of a simulation. Potential, long range interactions, pair lists computing,
outputs, `etc.` everything can be customised !

Jumos also include some code for analysing trajectories, either during the
simulation run or by reading frames in a file.

.. warning::
    This package is a work in progress, and is only usable at your own risk.

Jumos is separated in 5 main modules : `Universe`, `Atoms`, `Simulations`,
`Trajectories` and `Analysis`.

If you want to start running simulations, directely go to the :ref:`usage example <usage-example>`.
You can also explore the packages with the links below.

.. toctree::
    :maxdepth: 2

    units
    universe/index
    atoms/index
    simulations/index
    trajectories/index
    analysis/index



.. * :ref:`genindex`
   * :ref:`search`
