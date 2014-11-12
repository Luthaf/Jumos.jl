Universe
========

The Universe module defines some basic types for holding informations about a
simulation.

Vect3D
------

3-dimensionals vectors are very commons in molecular simulations. The ``Vect3D``
type is made to provide an easy interface to this kind of vector, implementing
all the usual operation : ``+, -`` between vector or with scalars; ``*, /`` with
scalars; dot (``*``) and cross (``^``) product between vectors; ``norm`` and
``normalize`` function.

.. Even if this class is convenient, it may be at the origin of a 10-100 slowdown
   function f()
      a = rand(3, 100)
      tic()
      for _=1:10^6
        for i=1:100
            a[1, i] += a[2, i]
            a[2, i] += a[3, i]
            a[3, i] += a[1, i]
        end
      end
      toc()
   end
   function g()
      a = Vect3D[Vect3D(rand(), rand(), rand()) for i=1:100]
      tic()
      for _=1:10^6
        for i=1:100
            a[i].x += a[i].y
            a[i].y += a[i].z
            a[i].z += a[i].x
        end
      end
      toc()
   end
   f();g()
   f() -> elapsed time: 0.003867119 seconds
   g() -> elapsed time: 0.477103004 seconds

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

.. function:: SimBox(u::Vector, v::Vector)

Creates a box with automatic type, with side lenghts from ``u`` and angles from
``v``.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real, a::Real, b::Real, c::Real)

Creates an orthorombic box of side lenghts ``Lx, Ly, Lz``, and angles ``a, b, c``.

.. function:: SimBox(Lx::Real, Ly::Real, Lz::Real)

Creates an orthorombic box of side lenghts ``Lx, Ly, Lz``.

.. function:: SimBox(L::Real)

Creates cubic box of side lenght ``L``.

.. function:: SimBox()

Creates cubic box of side lenght ``0.0``.

Manualy defined box type
""""""""""""""""""""""""

For all these constructors, the box type is specified as the first argument. This
allow for ``InfiniteBox`` and ``TriclinicBox`` with initial angles of :math:`90°`
to be constructed.

.. function:: SimBox(box_type, u::Vector, v::Vector)

Create a box by taking the lenghts from ``u`` and the angles from ``v``.

.. function:: SimBox(box_type, Lx::Real, Ly::Real, Lz::Real)

Create a box with side lenghts of ``Lx, Ly, Lz`` and angles of ``90°``.

.. function:: SimBox(box_type, L::Real)

Creates cubic box of side lenght ``L``.

.. function:: SimBox(box_type)

Creates cubic box of side lenght ``0.0``.

Indexing simulation box
^^^^^^^^^^^^^^^^^^^^^^^

.. function:: getindex(b::SimBox, i::String)

.. function:: getindex(b::SimBox, i::Int)

Boundary conditions and boxes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Only fully periodic boundary conditions are implemented for now. Its mean that
if a particle cross the boundary at some step, it will be wrapped up and will
appears at the opposite boundary.

Distances and boxes
^^^^^^^^^^^^^^^^^^^

The distance between two particle depends on the box type. In all cases, the
minimal image convention is used: the distance between two particles is the
minimal distance between all the images of theses particles.

TODO: link to distance function doc


Frame
-----

A ``Frame`` object holds the data from one step of a simulation. It is defined as

.. code-block:: julia

    Array3D = Vector{Vect3D{Float32}}
    NullableArray3D = Union(Void, Array3D)

    type Frame
        step::Integer
        box::SimBox
        topology::Topology
        positions::Array3D
        velocities::NullableArray3D
    end

`i.e.` it contains informations about the current step, the current
:ref:`box <type-SimBox>` shape, the current :ref:`topology <type-Topology>`, the
current positions, and maybe the current velocities. As the ``velocities`` field
may be ``nothing``, one should check for it's existency before using it in some
algorithm.

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

TODO
