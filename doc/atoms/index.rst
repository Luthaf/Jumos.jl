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
	- ``name``: the atom name;
	- ``symbol``: the atom chemical type;
	- ``mass``: the atom mass;
	- ``special::Dict{String, Any}``: all the other values: charge, dipolar moment …;
The atom name and symbol may not be the same: if there is two kind of hydrogen
atoms in a simulation, they may have the names **H1** and **H2** ; and share the 
same symbol **H**.

.. _type-Topology:

Topology
--------

A ``Topology`` store all the informations about the system. 

TODO: Topology[i] -> Atom

Topology functions
^^^^^^^^^^^^^^^^^^

.. function:: atomic_masses(::Topology)
TODO

Periodic table informations
---------------------------

The ``Atoms`` module also define two dictonaries who store informations about 
atoms:
	- ``ATOMIC_MASSES`` is a ``Dict{String, Float64}`` associating atoms symbols
	  and atomic masses, in :ref:`internal units <intenal_units>` ;
	- ``VDW_RADIUS`` is a ``Dict{String, Integer}`` associating atoms symbols
	  and Van der Waals radii, in :ref:`internal units <intenal_units>`.



