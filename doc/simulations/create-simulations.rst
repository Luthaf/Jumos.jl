.. _simulations:

Creating simulations
====================

.. _type-Simulation:

The Simulation type
-------------------

In `Jumos`, simulations are first-class citizen, `i.e.` objects bound to variables.
The main type for simulations is ``MolecularDynamic``, which can be constructed in
two ways:

.. function:: MolecularDynamic(timestep)

    Creates an empty molecular dynamic simulation using a Velocity-Verlet
    integrator with the specified timestep.

    Without any :ref:`thermostat <thermostat>` or :ref:`barostat <barostat>`, this
    performs a NVE integration of the system.

.. function:: MolecularDynamic(::Integrator)

    Creates an empty simulation with the specified :ref:`integrator <type-Integrator>`.

Default algorithms
------------------

Default algorithms for molecular dynamic are presented in the following table:

+---------------------+----------------------------------------------------------------------+
|  Simulation step    |                 Default algorithms                                   |
+=====================+======================================================================+
| Integration         | :ref:`Velocity-Verlet <type-VelocityVerlet>`                         |
+---------------------+----------------------------------------------------------------------+
| Forces computation  | :ref:`Naive computation <type-NaiveForceComputer>`                   |
+---------------------+----------------------------------------------------------------------+
| Control             | :ref:`Wrap particles in the box <type-WrapParticles>`                |
+---------------------+----------------------------------------------------------------------+
| Check               | :ref:`All positions are defined <type-AllPositionsAreDefined>`       |
+---------------------+----------------------------------------------------------------------+
| Compute             | `None`                                                               |
+---------------------+----------------------------------------------------------------------+
| Output              | `None`                                                               |
+---------------------+----------------------------------------------------------------------+


Using non default algorithms
----------------------------

The six following functions are used to to select specific algorithms for the
simulation. They allow to add and change all the algorithms, even in the middle
of a run.

.. function:: set_integrator(sim, integrator)

    Sets the simulation integrator to ``integrator``.

    Usage example:

    .. code-block:: julia

        # Creates the integrator directly in the function
        set_integrator(sim, Verlet(2.5))

        # Binds the integrator to a variable if you want to change a parameter
        integrator = Verlet(0.5)
        set_integrator(sim, integrator)
        run!(sim, 300)   # Run with a 0.5 fs timestep
        integrator.timestep = 1.5
        run!(sim, 3000)  # Run with a 1.5 fs timestep

.. function:: set_forces_computation(sim, forces_computer)

    Sets the simulation algorithm for forces computation to ``forces_computer``.

.. function:: add_check(sim, check)

    Adds a :ref:`check <simulation-checks>` to the simulation check list and
    issues a warning if the check is already present.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new check.
        add_check(sim, AllPositionsAreDefined())

.. function:: add_control(sim, control)

    Adds a :ref:`control <simulation-controls>` algorithm to the simulation
    list. If the control algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_control(sim, RescaleVelocities(300, 100))

.. function:: add_compute(sim, compute)

    Adds a :ref:`compute <simulation-computes>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new compute algorithm.
        add_compute(sim, EnergyCompute())

.. function:: add_output(sim, output)

    Adds an :ref:`output <simulation-outputs>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_output(sim, TrajectoryOutput("mytraj.xyz"))
