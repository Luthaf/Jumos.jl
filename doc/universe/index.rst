Universe
========

The Universe module defines some basic types for holding informations about a
simulation.

Frame
-----

Creating frames
^^^^^^^^^^^^^^^

TODO

Reding and writing frames from files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TODO

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

TODO: document functions

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
