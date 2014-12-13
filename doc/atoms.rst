Atoms
=====

This module create the link between human-readable and computer-readable
informations about the studied system. Humans prefers to use string labels for
molecules and atoms, whereas a computer only uses integers.

Atom type
---------

An ``Atom`` instance is a representation of atomic information. Think to an
``Atom`` as a cell in an augmented periodic table. The following fields are
accessibles:

- ``name`` : the atom name;
- ``symbol`` : the atom chemical type;
- ``mass`` : the atom mass;
- ``special::Dict{String, Any}`` : all the other values: charge, dipolar moment …;

The atom name and symbol may not be the same: if there is two kind of hydrogen
atoms in a simulation, they may have the names **H1** and **H2** ; and share the
same symbol **H**.

.. _type-Topology:

Topology
--------

A ``Topology`` instance store all the informations about the system : atomic types,
atomic composition of the system, bonds, angles, dihedral agnles and molecules.

For now, you can only access the atoms of the system, using integer indexing.
The following exemple show some operations you can do with this indexing.

.. code-block:: julia

    # topology is a Topology with 10 atoms

    atom = topology[3]  # Get a specific atom
    println(atom.name)  # Get the atom name

    atom.name = "H2"    # Set the atom name
    topology[3] = atom  # Set the 3rd atom of the topology

Topology functions
^^^^^^^^^^^^^^^^^^

.. function:: size(::Topology)

   This function return the number of atoms in the topology.

.. function:: atomic_masses(::Topology)

   This function return a ``Vector{Float64}`` containing the mass of all the atoms
   in the system. If no masses where provided, it uses the ``ATOMIC_MASSES``
   dictionnary to try to gess the values. If no value is found, the mass is set to
   :math:`0.0`. All the values are in :ref:`internal units <intenal_units>`.

Periodic table informations
---------------------------

The ``Atoms`` module also define two dictonaries who store informations about
atoms:

- ``ATOMIC_MASSES`` is a ``Dict{String, Float64}`` associating atoms symbols
   and atomic masses, in :ref:`internal units <intenal_units>` ;
- ``VDW_RADIUS`` is a ``Dict{String, Integer}`` associating atoms symbols
   and Van der Waals radii, in :ref:`internal units <intenal_units>`.
