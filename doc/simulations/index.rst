Simulations
===========

The simulation module contains code for molecular dynamic simulation. It
extensively uses custom types, which are presented in this section.

The first section (:ref:`simulation-steps`) describes how the code is organised, and is
worth reading to understand the design of this module. Then :ref:`an example
<simulation-usage>` shows how to use |Jumos| to run simple simulations, and
provides an example of the API usage. The :ref:`simulation <simulations>` part
presents most of the API in a more formal maner.

The :ref:`potentials` section lists the available potentials for use in |Jumos|,
and how you can easily use another potential.

.. toctree::
    :maxdepth: 2

    propagator
    molecular-dynamic
    compute
    output
    algorithms

.. _type-simulation:

``Simulation`` type
-------------------
