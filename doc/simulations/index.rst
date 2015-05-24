Simulations
===========

The simulation module contains types representing algorithms. The main type is the
:ref:`Simulation <type-simulation>` type, which is parametrized by a
:ref:`Propagator <type-propagator>`. This propagator will determine which kind of
simulation we are running: :ref:`Molecular Dynamics <type-MolecularDynamics>`;
Monte-Carlo; energy minimization; *etc.*

.. toctree::
    :maxdepth: 2

    propagator
    molecular-dynamics
    compute
    output

.. _type-simulation:

``Simulation`` type
-------------------

In |Jumos|, simulations are first-class citizen, `i.e.` objects bound to variables.
