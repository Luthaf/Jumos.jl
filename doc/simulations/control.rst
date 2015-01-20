.. _simulation-controls:

Controlling the simulation
==========================

While running a simulation, we often want to have control over some simulation
parameters: the temperature, the pressure, … This is the goal of the *Control*
algorithms.

Such algorithms are subtypes of ``BaseControl``, and can be added to a simulation
using the ``add_control`` function:

.. function:: add_control(sim, enforce)
    :noindex:

    Adds a control algorithm to the simulation. If the algorithm is already
    present, a warning is issued.

    Example:

    .. code-block:: julia

        sim = MolecularDynamic(1.0)

        add_control(sim, RescaleVelocities(300, 100))

.. _thermostat:

Controlling the temperature: Thermostats
----------------------------------------

Various algorithms are available to control the temperature of a simulation and
perform pseudo NVT simulations. The following thermostating algorithms are
currently implemented:

.. jl:type:: VelocityRescaleThermostat

    The velocity rescale algorithm controls the temperature by rescaling all the
    velocities when the temperature differs exceedingly from the desired temperature.

    The constructor takes two parameters: the desired temperature and a tolerance
    interval. If the absolute difference between the current temperature and the
    desired temperature is larger than the tolerance, this algorithm rescales the
    velocities.

    .. code-block:: julia

        sim = MolecularDynamic(2.0)

        # This sets the temperature to 300K, with a tolerance of 50K
        thermostat = VelocityRescaleThermostat(300, 50)

        add_control(sim, thermostat)

.. jl:type:: BerendsenThermostat

    The berendsen thermostat sets the simulation temperature by exponentially
    relaxing to a desired temperature. A more complete description of this
    algorithm can be found in the original article [#berendsen]_.

    The constructor takes as parameters the desired temperature, and the coupling
    parameter, expressed in simulation timestep units. A coupling parameter of
    100, will give a coupling time of :math:`150\ fs` if the simulation timestep
    is :math:`1.5\ fs`, and a coupling time of :math:`200\ fs` if the timestep
    is :math:`2.0\ fs`.

    .. function:: BerendsenThermostat(T, [coupling])

        Creates a Berendsen thermostat at the temperature ``T`` with a coupling
        parameter of ``coupling``. The default values for ``coupling`` is :math:`100`.

    .. code-block:: julia

        sim = MolecularDynamic(2.0)

        # This sets the temperature to 300K
        thermostat = BerendsenThermostat(300)

        add_control(sim, thermostat)

.. _barostat:

Controlling the pressure: Barostats
-----------------------------------

.. jl:type:: BerendsenBarostat

    TODO

Other controls
--------------

.. _type-WrapParticles:

.. jl:type:: WrapParticles

    This control wraps the positions of all the particles inside the :ref:`unit
    cell <type-UnitCell>`.

    This control is present by default in the molecular dynamic simulations.

Adding other controls
---------------------

To add a new type of control to a simulation, the main way is to subtype
``BaseControl``, and provide two specialised methods: ``call(::BaseControl,
::MolecularDynamic)`` and the optional ``setup(::BaseControl, ::MolecularDynamic)``.
The ``call`` method should contain the algorithm inplementation, and the ``setup``
method is called once at each simulation start. It should be used to add add some
:ref:`computation algorithm <simulation-computes>` to the simulation.

.. [#berendsen] H.J.C. Berendsen, *et al.* J. Chem Phys **81**, 3684 (1984); doi: 10.1063/1.448118
