Simulations
===========

The simulation module is were all the simulation code falls. This module allows
you to define and run molecular dynamic simulations. It extensively uses custom
types, all of them are presented here.


Basic usage
-----------

The :ref:`first <simulation-steps>` section describe how the code is organised, and is
worth reading to understand the design of this module. Then :ref:`an example <simulation-usage>`
show how to use `Jumos` to run a simple simulations, and is an example of
the API usage. The :ref:`simulation <simulations>` part expose most of the API,
in a more formal maner.

The :ref:`potentials` section list the available potentials for use in `Jumos`,
and how you can easily use an other potential.

.. toctree::
    :maxdepth: 2

    steps
    usage-example
    create-simulations
    potentials


Use of custom algorithms
------------------------

The others sections describe the existing algorithms and potentials, and explain
how to expand Jumos with your own algorithms.


.. toctree::
    :maxdepth: 2

    integrator
    forces
    enforce
    check
    compute
    output
