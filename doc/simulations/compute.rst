.. _type-Compute:

Computing values of interest
============================

To compute physical values from a simulation, we can use algorithms represented by
subtypes of ``Compute`` and associate these algorithms to a simulation.

Users don't usualy need to use these compute algorithms directly, as the output
algorithms (see :ref:`type-output`) set the needed computations by themself.

Computed values can have various usages: they may be used in :ref:`outputs
<type-output>`, or in :ref:`controls <type-control>`. The data is shared between
algorithms using the ``Universe.data`` field. This field is a dictionnary associating
symbols and any kind of value.

This page of documentation presents the implemented computations. Each computation
can be associated with a specific :ref:`simulation <type-Simulation>` using the
``push!`` function.


.. function:: push!(simulation, compute)
    :noindex:

    Adds a :ref:`compute <type-Compute>` algorithm to the simulation list. If the
    algorithm is already present, a warning is issued. Usage example:

    .. code-block:: julia

        sim = Simulation(:md, 1.0) # Create a simulation

        # Do not forget the parentheses to instanciate the computation
        push!(sim, MyCompute())

        propagate!(sim, universe, 5000)

        # You can access the last computed value in the sim.data dictionnary
        universe.data[:my_compute]


You can also call directly any instance of ``MyCompute``:

.. code-block:: julia

    universe = Universe() # Create an universe
    # ...

    compute = MyCompute() # Instanciate the compute
    value = compute(universe) # Compute the value


The following paragraphs sums up the implemented computations, giving for each
algorithm the return value (for direct calling), and the associated keys in
``Universe.data``.

Energy related values
---------------------

.. jl:type:: TemperatureCompute

    Computes the temperature of the universe.

    **Key**: ``:temperature``

    **Return value**: The current frame temperature.

.. jl:type:: EnergyCompute

    Computes the potential, kinetic and total energy of the current simulation step.

    **Keys**: ``:E_kinetic``, ``:E_potential``, ``:E_total``

    **Return value**: A tuple containing the kinetic, potential and total energy.

    .. code-block:: julia

        energy = EnergyCompute()

        # unpacking the tuple
        E_kinetic, E_potential, E_total = energy(universe)

        # accessing the tuple values
        E = energy(sim)

        E_kinetic = E[1]
        E_potential = E[2]
        E_total = E[3]

Volume
------

.. jl:type:: VolumeCompute

    Computes the volume of the current :ref:`unit cell <type-UnitCell>`.

    **Key**: ``:volume``

    **Return value**: The current cell volume

Pressure
--------

.. jl:type:: PressureCompute

    TODO

    **Key**:

    **Return value**:
