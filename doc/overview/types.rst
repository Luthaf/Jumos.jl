Main types
==========

|Jumos| is organised around two main types: the ``Universe`` hold data about the
system we are simulating; and the ``Simulation`` type hold data about the algorithms
we should use for the simulation.

Universe
--------

The ``Universe`` type contains data. It is built around four other basic types:

* The :ref:`Topology <type-Topology>` contains data about the atomic organisation,
  *i.e.* the particles, bonds, angles and dihedral angles in the system;
* The :ref:`UnitCell <type-UnitCell>` contains data about the bounding box of the
  simulation;
* The :ref:`Interactions <type-Interactions>` type contains data about the
  :ref:`potentials <potentials>` to use for the atoms in the system;
* The :ref:`Frame <type-Frame>` type contains raw data about the positions and maybe
  velocities of the particles in the system;

Simulation
----------

The ``Simulation`` type contains algorithms. The :ref:`progagator <type-propagator>`
algorithm is the one responsible for propagating the ``Universe`` along the
simulation. It also contains some analysis algorithms (called
:ref:`compute <type-compute>` in |Jumos|); and some :ref:`output <type-output>`
algorithms, to save data during the simulation run.
