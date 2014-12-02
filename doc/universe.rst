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

.. _type-SimBox:

Simulation Box
--------------

A simulation box (``SimBox`` type) is the virtual container in which all the
particles of a simulation moves. There are three differents types of simulation
boxes :

- Infinite boxes (``InfiniteBox``) does not have any boundaries. Any movement
  is allowed inside these boxes;
- Orthorombic boxes (``OrthorombicBox``) have up to three independent lenght;
  all the angles of the box are set to 90° (:math:`\pi/2` radians)
- Triclinic boxes (``TriclinicBox``) have 6 independent parameters: 3 lenght and
  3 angles.

Creating simulation box
^^^^^^^^^^^^^^^^^^^^^^^

Automatic box types
"""""""""""""""""""

These constructors try to guess the box type according the following algorithm:
if the box angles are all :math:`90°`, then the box is an ``OrthorombicBox``.
Else, it is a ``TriclinicBox``.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)

    Creates a box of side lenghts ``Lx, Ly, Lz``, and angles ``a, b, c``.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real)

    Creates an orthorombic box of side lenghts ``Lx, Ly, Lz``.

.. function:: SimBox(L::Real)

    Creates cubic box of side lenght ``L``.

.. function:: SimBox()

    Creates cubic box of side lenght ``0.0``.

.. function:: SimBox(u::Vector)
.. function:: SimBox(u::Vector, v::Vector)

    If the size match, these functions expands the vectors and return one of the
    previous constructors, *e.g.* if ``u == [30, 40, 30]``, ``SimBox(u) == SimBox(30, 40, 30)``.

Manualy defined box type
""""""""""""""""""""""""

For all these constructors, the box type is specified as the first argument. This
allow for ``InfiniteBox`` and ``TriclinicBox`` with initial angles of :math:`90°`
to be constructed.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real, btype::Type{AbstractBoxType})

    Create a box with lenghts ``Lx, Ly, Lz``, angles ``a, b, c``, and type ``btype``.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real, btype)
.. function:: SimBox(L::Real, btype)
.. function:: SimBox(btype)
.. function:: SimBox(u::Vector, v::Vector, btype)
.. function:: SimBox(u::Vector, btype)

    All these functions have the same behaviour than the one with automatic box type,
    excepted than the box type is taken to be equal to ``btype``.

Indexing simulation box
^^^^^^^^^^^^^^^^^^^^^^^

You can acces to the box size and angles either directely, or by integer indexing.

.. function:: getindex(b::SimBox, i::Int)

Calling ``b[i]`` will return the corresponding length or angle : for ``i in [1:3]``,
you get the ``i``:superscript:`th` lenght, and for ``i in [4:6]``, you get the
angles.

If you make a lot of call to this kind of indexing, direct field access should be
more efficient. The internal fields of a box are : the three lenghts ``x, y, z``,
and the three angles ``a, b, c``.

Boundary conditions and boxes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Only fully periodic boundary conditions are implemented for now. Its mean that
if a particle cross the boundary at some step, it will be wrapped up and will
appears at the opposite boundary.

Distances and boxes
^^^^^^^^^^^^^^^^^^^

The distance between two particle depends on the box type. In all cases, the
minimal image convention is used: the distance between two particles is the
minimal distance between all the images of theses particles. This is explicited
in the :ref:`distances` part of this documentation.


Frame
-----

A ``Frame`` object holds the data from one step of a simulation. It is defined as

.. code-block:: julia

    type Frame
        step::Integer
        box::SimBox
        topology::Topology
        positions::Array3D
        velocities::Array3D
    end

`i.e.` it contains informations about the current step, the current
:ref:`box <type-SimBox>` shape, the current :ref:`topology <type-Topology>`, the
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

The main goal of the ``Trajectories``module is to read or write frames from or to
files. See the :ref:`documentation <trajectories>` for more informations.
