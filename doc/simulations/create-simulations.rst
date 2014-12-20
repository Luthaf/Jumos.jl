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

    Create an empty molecular dynamic simulation using a Velocity-Verlet
    integrator with the specified timestep.

    Without any :ref:`thermostat <thermostat>` or :ref:`barostat <barostat>`, this
    perform a NVE integration of the system.

.. function:: MolecularDynamic(::Integrator)

    Create an empty simulation with the specified :ref:`integrator <type-Integrator>`.

Default algorithms
------------------

By default, the following algorithm are used in the molecular dynamic run.

+---------------------+----------------------------------------------------------------------+
|  Simulation step    |                 Default algorithms                                   |
+=====================+======================================================================+
| Integration         | :ref:`Velocity-Verlet <type-VelocityVerlet>`                         |
+---------------------+----------------------------------------------------------------------+
| Forces computation  | :ref:`Naive computation <type-NaiveForceComputer>`                   |
+---------------------+----------------------------------------------------------------------+
| Enforce             | :ref:`Wrap particles in the box <type-WrapParticles>`                |
+---------------------+----------------------------------------------------------------------+
| Check               | :ref:`All positions are defined <type-AllPositionsAreDefined>`       |
+---------------------+----------------------------------------------------------------------+
| Compute             | `None`                                                               |
+---------------------+----------------------------------------------------------------------+
| Output              | `None`                                                               |
+---------------------+----------------------------------------------------------------------+


Using non default algorithms
----------------------------

The six following functions are the main way to select some algorithm for the
simulation. They allow to add other checks, other outputs, and to change the
integrator, even in the middle of a run.

.. function:: set_integrator(sim, integrator)

    Set the simulation integrator to ``integrator``.

    Usage example:

    .. code-block:: julia

        # Create the integrator directly in the function
        set_integrator(sim, Verlet(2.5))

        # Bind the integrator to a variable if you want to change a parameter
        integrator = Verlet(0.5)
        set_integrator(sim, integrator)
        run!(sim, 300)   # Run with a 0.5 fs timestep
        integrator.timestep = 1.5
        run!(sim, 3000)  # Run with a 1.5 fs timestep

.. function:: set_forces_computation(sim, forces_computer)

    Set the simulation alorithm for forces computation to ``forces_computer``.

.. function:: add_check(sim, check)

    Add a :ref:`check <simulation-checks>` to the simulation check list. If the
    check is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new check.
        add_check(sim, AllPositionsAreDefined())

.. function:: add_enforce(sim, enforce)

    Add an :ref:`enforce <simulation-enforces>` algorithm to the simulation
    list. If the enforce algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_enforce(sim, RescaleVelocities(300, 100))

.. function:: add_compute(sim, compute)

    Add a :ref:`compute <simulation-computes>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        # Note the parentheses, needed to instanciate the new compute algorithm.
        add_compute(sim, EnergyCompute())

.. function:: add_output(sim, output)

    Add an :ref:`output <simulation-outputs>` algorithm to the simulation
    list. If the algorithm is already present, a warning is issued.

    Usage example:

    .. code-block:: julia

        add_output(sim, TrajectoryOutput("mytraj.xyz"))
