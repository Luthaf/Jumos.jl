Universes
=========

.. toctree::
    :maxdepth: 2

    cell
    topology
    frame
    interactions
    potentials

.. _type-universe:

``Universe`` type
-----------------

The ``Universe`` type contains data about a simulation. In order to build an universe,
you can use the following functions.


.. function:: Universe(cell, topology)

    Create a new universe with the :ref:`simulation cell <type-UnitCell>` ``cell``
    and the :ref:`type-topology` ``topology``.

.. function:: setframe!(universe, frame)

    Set the :ref:`type-Frame` of ``universe`` to ``frame``.

.. function:: setcell!(universe, cell)

    Set the :ref:`simulation cell <type-UnitCell>` of ``universe`` to ``cell``.

.. function:: setcell!(universe, [celltype], paremeters...)

    Set the :ref:`simulation cell <type-UnitCell>` of ``universe`` to
    ``UnitCell(parameters..., celltype)``.

.. function:: add_atom!(u::Universe, atom::Atom)

    Add the :ref:`Atom <type-Atom>` ``atom`` to the ``universe`` topology.

.. function:: add_liaison!(u::Universe, atom_i::Atom, atom_j::Atom)

    Add a liaison between the atoms at indexes ``i`` and ``j`` in the ``universe``
    topology.

.. function:: remove_atom!(u::Universe, index)

    Remove the atom at index ``i`` in the ``universe`` topology.

.. function:: remove_liaison!(u::Universe, atom_i::Atom, atom_j::Atom)

    Remove any liaison between the atoms at indexes ``i`` and ``j`` in the
    ``universe`` topology.

The :func:`add_interaction!` function is already documented in the ``Interactions``
section of this document.


Loading initial configurations from files
-----------------------------------------

It is often usefull to load initial configurations from files, instead of building it
by hand. The :ref:`Trajectories <trajectories>` module provides functionalities for
this.
