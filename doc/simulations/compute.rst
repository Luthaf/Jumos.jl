.. _simulation-computes:

Computing values of interest
============================

Various values can be computed from a simulation. The algorithms used to compute
these values are represented in `Jumos` by subtypes of ``Basecompute`` and stored
by a simulation.

Users don't usualy need to use ``Basecompute`` directly, as all the output
capacities are provided by the :ref:`outputs <simulation-outputs>`. Computed values
can have various usages: they may be used in :ref:`outputs <simulation-outputs>`,
or in :ref:`controls <simulation-controls>`. The data is shared between algorithms
using the ``MolecularDynamic.data`` field. This field is a dictionnary associating
symbols and any kind of value.

This page of documentation present the implemented computations. Each computation
can be registered with a specific :ref:`simulation <type-Simulation>` using the
``add_compute`` function.

.. function:: add_compute(::MolecularDynamic, ::BaseCompute)
    :noindex:

    This function register a computation for a given simulation. Example usage:

    .. code-block:: julia

        sim = MolecularDynamic() # Create a simulation
        # ...

        # Don't forget the parentheses to instanciate the computation
        add_compute(sim, MyCompute())

        run!(sim, 10)

        # You can access the last computed value in the sim.data dictionnary
        sim.data[:my_compute]


A more advanced usage can be done by directly calling the instance of ``MyCompute``.

.. code-block:: julia

    sim = MolecularDynamic() # Create a simulation
    # ...

    compute = MyCompute() # Instanciate the compute
    value = compute(sim) # Compute the value


The following paragraphs sum up the implemented computations, given for each of
them the return value (for direct calling), and the setted keys of
``MolecularDynamic.data``.

Energy related values
---------------------

.. jl:type:: TemperatureCompute

    Compute the temperature of the simulation. All the masses have to be set.

    **Key**: ``:temperature``

    **Return value**: The current frame temperature.

.. jl:type:: EnergyCompute

    Compute the potential, kinetic and total energy of the current simulation step.

    **Keys**: ``:E_kinetic``, ``:E_potential``, ``:E_total``

    **Return value**: A tuple containing the kinetic, potential and total energy.

    .. code-block:: julia

        energy = EnergyCompute()
        sim = MolecularDynamic()

        # unpacking the tuple
        E_kinetic, E_potential, E_total = energy(sim)

        # accessing the tuple values
        E = energy(sim)

        E_kinetic = E[1]
        E_potential = E[2]
        E_total = E[3]

Volume
------

.. jl:type:: VolumeCompute

    Compute the volume of the current :ref:`unit cell <type-UnitCell>`.

    **Key**: ``:volume``

    **Return value**: The current cell volume

Pressure
--------

.. jl:type:: PressureCompute

    TODO

    **Key**:

    **Return value**:

Computing other values
----------------------

To add your own compute (``MyCompute``), you have to subtype ``BaseCompute`` and
provide a specialised ``call`` function with the following signature:

.. function:: call(::MyCompute, ::MolecularDynamic)

    This function can set a ``MolecularDynamic.data`` entry with any kind of key
    to store the computed value.
