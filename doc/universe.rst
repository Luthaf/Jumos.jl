Universe
========

The Universe module defines some basic types for holding informations about a
simulation.

Array3D
-------

3-dimensionals vectors are very commons in molecular simulations. The ``Array3D``
type implement arrays of this kind of vectors, implementing all the usual
operations between it's components. If ``A`` is an ``Array3D`` and ``i`` an integer,
``A[i]`` is a 3-dimensional vector implementing ``+, -`` between vector,
``.+, .-, .*, */`` between vectors and scalars; ``dot`` and ``cross`` products,
and the ``unit!`` function, normalizing its argument.

.. _type-UnitCell:

Simulation Cell
---------------

A simulation cell (``UnitCell`` type) is the virtual container in which all the
particles of a simulation moves. There are three differents types of simulation
cells :

- Infinite cells (``InfiniteCell``) does not have any boundaries. Any mouvement
  is allowed inside these cells;
- Orthorombic cells (``OrthorombicCell``) have up to three independent lenghts;
  all the angles of the cell are set to 90° (:math:`\pi/2` radians)
- Triclinic cells (``TriclinicCell``) have 6 independent parameters: 3 lenghts and
  3 angles.

Creating simulation cell
^^^^^^^^^^^^^^^^^^^^^^^^

Automatic cell types
""""""""""""""""""""

These constructors try to guess the cell type according the following algorithm:
if the cell angles are all :math:`90°`, then the cell is an ``OrthorombicCell``.
Else, it is a ``TriclinicCell``.

.. function:: UnitCell(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)

    Creates a cell of side lenghts ``Lx, Ly, Lz``, and angles ``a, b, c``.

.. function:: UnitCell(Lx::Real, Ly::Real, Lz::Real)

    Creates an orthorombic cell of side lenghts ``Lx, Ly, Lz``.

.. function:: UnitCell(L::Real)

    Creates cubic cell of side lenght ``L``.

.. function:: UnitCell()

    Creates cubic cell of side lenght ``0.0``.

.. function:: UnitCell(u::Vector)
.. function:: UnitCell(u::Vector, v::Vector)

    If the size match, these functions expands the vectors and return one of the
    previous constructors, *e.g.* if ``u == [30, 40, 30]``, ``UnitCell(u) == UnitCell(30, 40, 30)``.

Manualy defined cell type
"""""""""""""""""""""""""

For all these constructors, the cell type is specified as the first argument. This
allow for ``InfiniteCell`` and ``TriclinicCell`` with initial angles of :math:`90°`
to be constructed.

.. function:: UnitCell(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real, celltype::Type{AbstractCellType})

    Create a cell with lenghts ``Lx, Ly, Lz``, angles ``a, b, c``, and type ``celltype``.

.. function:: UnitCell(Lx::Real, Ly::Real, Lz::Real, celltype)
.. function:: UnitCell(L::Real, celltype)
.. function:: UnitCell(celltype)
.. function:: UnitCell(u::Vector, v::Vector, celltype)
.. function:: UnitCell(u::Vector, celltype)

    All these functions have the same behaviour than the one with automatic cell type,
    excepted than the cell type is taken to be equal to ``celltype``.

Indexing simulation cell
^^^^^^^^^^^^^^^^^^^^^^^^

You can acces to the cell size and angles either directely, or by integer indexing.

.. function:: getindex(b::UnitCell, i::Int)

Calling ``b[i]`` will return the corresponding length or angle : for ``i in [1:3]``,
you get the ``i``:superscript:`th` lenght, and for ``i in [4:6]``, you get the
angles.

If you make a lot of call to this kind of indexing, direct field access should be
more efficient. The internal fields of a cell are : the three lenghts ``x, y, z``,
and the three angles ``a, b, c``.

Boundary conditions and cells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Only fully periodic boundary conditions are implemented for now. Its mean that
if a particle cross the boundary at some step, it will be wrapped up and will
appears at the opposite boundary.

Distances and cells
^^^^^^^^^^^^^^^^^^^

The distance between two particle depends on the cell type. In all cases, the
minimal image convention is used: the distance between two particles is the
minimal distance between all the images of theses particles. This is explicited
in the :ref:`distances` part of this documentation.

.. _type-Frame:

Frame
-----

A ``Frame`` object holds the data from one step of a simulation. It is defined as

.. code-block:: julia

    type Frame
        step::Integer
        cell::UnitCell
        topology::Topology
        positions::Array3D
        velocities::Array3D
    end

`i.e.` it contains informations about the current step, the current
:ref:`cell <type-UnitCell>` shape, the current :ref:`topology <type-Topology>`, the
current positions, and maybe the current velocities. If there is no velocities
information, the velocities ``Array3D`` is a 0-sized array.

Creating frames
^^^^^^^^^^^^^^^

There are two ways to create frames: either explicitly or implicity. Explicit
creation uses one of the constructors below. Implicit creation occurs while
reading frames from a stored trajectory or from running a simulation.

The Frame type have the following constructors:

.. function:: Frame(::Topology)

    Create a frame given a topology. The arrays are pre-allocated to store data
    according to the topology.

.. function:: Frame()

    Create an empty frame, with a 0-atoms topology.

Reding and writing frames from files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The main goal of the ``Trajectories`` module is to read or write frames from or to
files. See the :ref:`documentation <trajectories>` for more informations.
