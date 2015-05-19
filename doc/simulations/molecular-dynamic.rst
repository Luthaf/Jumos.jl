.. _simulations:

Creating simulations
====================

.. _type-Simulation:

The Simulation type
-------------------

In |Jumos|, simulations are first-class citizen, `i.e.` objects bound to variables.
The main type for simulations is ``MolecularDynamic``, which can be constructed in
two ways:

.. function:: MolecularDynamic(timestep)

    Creates an empty molecular dynamic simulation using a Velocity-Verlet
    integrator with the specified timestep.

    Without any :ref:`thermostat <thermostat>` or :ref:`barostat <barostat>`, this
    performs a NVE integration of the system.

.. function:: MolecularDynamic(::Integrator)

    Creates an empty simulation with the specified :ref:`integrator <simulation-integrator>`.

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
