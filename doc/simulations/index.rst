Simulations
===========

The simulation module contains types representing algorithms. The main type is the
:ref:`Simulation <type-simulation>` type, which is parametrized by a :ref:`Propagator
<type-propagator>`. This propagator will determine which kind of simulation we are
running: :ref:`Molecular Dynamics <type-MolecularDynamics>`; Monte-Carlo; energy
minimization; *etc.*

.. note::
    Only molecular dynamic is implemented in |Jumos| for now, but at least
    Monte-Carlo and energetic optimization should follow. If you are interested in
    implementing such methods, please signal yourself in the `Gihtub issues`_ list.

.. _Gihtub issues : https://github.com/Luthaf/Jumos.jl/issues

.. toctree::
    :maxdepth: 2

    propagator
    molecular-dynamics
    compute
    output

.. _type-simulation:

``Simulation`` type
-------------------

In |Jumos|, simulations are first-class citizen, *i.e.* objects bound to variables.


.. function:: Simulation(propagator::Propagator)

    Create a simulation with the specified ``propagator``.

.. function:: Simulation(propagator::Symbol, args...)

    Create a simulation with a :ref:`propagator <type-Propagator>` which type is
    given by the ``propagator`` symbol. The ``args`` are passed to the propagator
    constructor.

    If ``propagator`` takes one of the ``:MD``, ``:md`` and ``:moleculardynamics``
    values, a :ref:`MolecularDynamics <type-MolecularDynamics>` propagator is
    created.
