Computing the forces
====================

.. _type-NaiveForceComputer:

Naive force computation
^^^^^^^^^^^^^^^^^^^^^^^

The ``NaiveForceComputer`` algorithm compute the forces by iterating over all the
pairs of atoms, and caling the appropriate interaction potential. This algorithm
is the default in `Jumos`.

New algorithm for forces computations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a new force computation algorithm, you have to subtype ``BaseForcesComputer``,
and provide the method ``call(::BaseForcesComputer, forces::Array3D, frame::Frame, interactions)``.

This method should fill the forces array with the forces acting on each particles:
``forces[i]`` should be the 3D vector of forces acting on the atom ``i``. In order
to do this, the algorithm can use the ``frame.posistions`` and ``frame.velocities``.
The ``interactions`` is a dictionary associating tuples of integers (the atoms types)
to :ref:`potential <potentials>`. The ``get_potential`` function can be usefull.

.. function:: get_potential(interactions, topology, i, j)

    Return the potential between the atom i and the atom j in the topology.

Due to the internal unit system, forces returned by the potentials are in
:math:`kJ/(mol \cdot A)`, and should be in :math:`uma \cdot A / fs^2` for being
used with the newton equations.  The conversion can be handled by the unexported
``Simulations.force_array_to_internal!`` function, converting the values of an
Array3D from :math:`kJ/(mol \cdot A)` to :math:`uma \cdot A / fs^2`.
