Topology
========

The ``Topology`` type creates the link between human-readable and computer-readable
information about the system. Humans prefer to use string labels for molecules and
atoms, whereas a computer will only uses integers.

.. _type-atom:

Atom type
---------

An ``Atom`` instance is a representation of a type of particle in the system.
It is paramerized by an ``AtomType``, which can be one of:

* ``Element`` : an element in the perdiodic classification;
* ``DummyAtom`` : a dummy atom, for particles without interactions;
* ``CorseGrain`` : corse-grain particle, for corse-grain simulations;
* ``UnknownAtom`` : All the other kind of particles.

You can access the following fields for all atoms:

- ``label::Symbol`` : the atom name;
- ``mass`` : the atom mass;
- ``charge`` : the atom charge;
- ``properties::Dict{String, Any}`` : any other property: dipolar moment, *etc.*;

.. function:: Atom([label, type])

    Creates an atom with the ``label`` label. If ``type`` is provided, it is used as
    the Atom type. Else, a type is guessed according to the following procedure: if
    the ``label`` is in the periodic classification, the the atom is an ``Element``.
    Else, it is a ``CorseGrain`` atom.

    .. code-block:: jlcon

        julia> Atom()
        "Atom{UnknownAtom}"

        julia> Atom("He")
        "Atom{Element} He"

        julia> Atom("CH4")
        "Atom{CorseGrain} CH4"

        julia> Atom("Zn", DummyAtom)
        "Atom{DummyAtom} Zn"

.. function:: mass(label::Symbol)

    Try to guess the mass associated with an element, from the periodic table data.
    If no value could be found, the ``0.0`` value is returned.

.. function:: mass(atom::Atom)

    Return the atomic mass if it was set, or call the function ``mass(atom.label)``.

.. _type-Topology:

Topology
--------

A ``Topology`` instance stores all the information about the system : atomic types,
atomic composition of the system, bonds, angles, dihedral agnles and molecules.


.. function:: Topology([natoms = 0])

    Create an empty topology with space for ``natoms`` atoms.

Atoms in the system can be accesed using integer indexing. The following example
shows a few operations available on atoms:

.. code-block:: julia

    # topology is a Topology with 10 atoms

    atom = topology[3]  # Get a specific atom
    println(atom.label) # Get the atom label

    atom.mass = 42.9    # Set the atom mass
    topology[5] = atom  # Set the 5th atom of the topology

Topology functions
^^^^^^^^^^^^^^^^^^

.. function:: size(topology)

   This function returns the number of atoms in the topology.

.. function:: atomic_masses(topology)

   This function returns a ``Vector{Float64}`` containing the masses of all the
   atoms in the system. If no mass was provided, it uses the ``ATOMIC_MASSES``
   dictionnary to guess the values. If no value is found, the mass is set to
   :math:`0.0`. All the values are in :ref:`internal units <intenal_units>`.

.. function:: add_atom!(topology, atom)
    :noindex:

    Add the ``atom`` Atom to the end of ``topology``.

.. function:: remove_atom!(topology, i)
    :noindex:

    Remove the atom at index ``i`` in ``topology``.

.. function:: add_liaison!(topology, i, j)
    :noindex:

    Add a liaison between the atoms ``i`` and ``j``.

.. function:: remove_liaison!(topology, i, j)
    :noindex:

    Remove any existing liaison between the atoms ``i`` and ``j``.

.. function:: dummy_topology(natoms)

    Create a topology with ``natoms`` of type ``DummyAtom``. This function exist
    mainly for testing purposes.

Periodic table information
---------------------------

The ``Universes`` module also exports two dictonaries that store information about
atoms:

* ``ATOMIC_MASSES`` is a ``Dict{String, Float64}`` associating atoms symbols
  and atomic masses, in :ref:`internal units <intenal_units>` ;
* ``VDW_RADIUS`` is a ``Dict{String, Integer}`` associating atoms symbols
  and Van der Waals radii, in :ref:`internal units <intenal_units>`.
