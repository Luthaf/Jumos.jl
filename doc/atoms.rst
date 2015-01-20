Atoms
=====

This module creates the link between human-readable and computer-readable
information about the studied system. Humans prefer to use string labels for
molecules and atoms, whereas a computer only uses integers.

Atom type
---------

An ``Atom`` instance is a representation of atomic information. Think of an
``Atom`` as a cell in an augmented periodic table. You can access the following
fields :

- ``name`` : the atom name;
- ``symbol`` : the atom chemical type;
- ``mass`` : the atom mass;
- ``special::Dict{String, Any}`` : all the other values: charge, dipolar moment …;

The atom name and symbol may not be the same: if there are two kinds of hydrogen
atoms in a simulation, they may have the names **H1** and **H2** ; and share the
same symbol **H**.

.. _type-Topology:

Topology
--------

A ``Topology`` instance stores all the information about the system : atomic types,
atomic composition of the system, bonds, angles, dihedral agnles and molecules.

Atoms of the system can be accesed using integer indexing. The following example
shows a few operations available on atoms:

.. code-block:: julia

    # topology is a Topology with 10 atoms

    atom = topology[3]  # Get a specific atom
    println(atom.name)  # Get the atom name

    atom.name = "H2"    # Set the atom name
    topology[5] = atom  # Set the 5th atom of the topology

Topology functions
^^^^^^^^^^^^^^^^^^

.. function:: size(::Topology)

   This function returns the number of atoms in the topology.

.. function:: atomic_masses(::Topology)

   This function returns a ``Vector{Float64}`` containing the masses of all the
   atoms in the system. If no mass was provided, it uses the ``ATOMIC_MASSES``
   dictionnary to guess the values. If no value is found, the mass is set to
   :math:`0.0`. All the values are in :ref:`internal units <intenal_units>`.

Periodic table information
---------------------------

The ``Atoms`` module also defines two dictonaries that store information about
atoms:

``ATOMIC_MASSES`` is a ``Dict{String, Float64}`` associating atoms symbols
and atomic masses, in :ref:`internal units <intenal_units>` ;

``VDW_RADIUS`` is a ``Dict{String, Integer}`` associating atoms symbols
and Van der Waals radii, in :ref:`internal units <intenal_units>`.
