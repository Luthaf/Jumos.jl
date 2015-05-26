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


.. function:: push!(sim, compute)

    Adds a :ref:`compute <type-Compute>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new compute algorithm.
        add_compute(sim, EnergyCompute())

.. function:: push!(sim, output)

    Adds an :ref:`output <type-Output>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_output(sim, TrajectoryOutput("mytraj.xyz"))
