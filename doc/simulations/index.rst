Simulations
===========

The simulation module contains types representing algorithms. The main type is the
:ref:`Simulation <type-simulation>` type, which is parametrized by a :ref:`Propagator
<type-propagator>`. This propagator will determine which kind of simulation we are
running: :ref:`Molecular Dynamics <type-MolecularDynamics>`; Monte-Carlo; energy
minimization; *etc.*

.. note::
    Only molecular dynamic is implemented in |Jumos| for now, but at least
    Monte-Carlo and energetic optimization should follow.

.. toctree::
    :maxdepth: 2

    molecular-dynamics
    compute
    output

.. _type-propagator:

Propagator
==========

The ``Propagator`` type is responsible for generating new :ref:`frames <type-frame>`
in the simulated :ref:`universe <type-universe>`. If you want to help adding a new
propagator to |Jumos|, please signal yourself in the `Gihtub issues`_ list.

.. _Gihtub issues : https://github.com/Luthaf/Jumos.jl/issues

.. _type-simulation:

``Simulation`` type
-------------------

In |Jumos|, simulations are first-class citizen, *i.e.* objects bound to variables.
The following constructors should be used to create a new simulation:

.. function:: Simulation(propagator::Propagator)

    Create a simulation with the specified ``propagator``.

.. function:: Simulation(propagator::Symbol, args...)

    Create a simulation with a :ref:`propagator <type-Propagator>` which type is
    given by the ``propagator`` symbol. The ``args`` are passed to the propagator
    constructor.

    If ``propagator`` takes one of the ``:MD``, ``:md`` and ``:moleculardynamics``
    values, a :ref:`MolecularDynamics <type-MolecularDynamics>` propagator is
    created.


The main function to run the simulation is the :func:`propagate!` function.

.. function:: propagate!(simulation, universe, nsteps)

    Propagate an ``universe`` for ``nsteps`` steps, using the ``simulation`` method.
    Usage example:

    .. code-block:: jlcon

        julia> sim = Simulation(:MD, 1.0)

        julia> universe # This should be an universe, either read from a file or built by hand

        julia> propagate!(sim, universe, 4000) # Run the MD simulation for 4000 steps
