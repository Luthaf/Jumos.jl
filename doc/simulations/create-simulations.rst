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

TODO
