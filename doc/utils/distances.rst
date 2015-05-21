.. _distances:

Periodic boundary conditions and distances computations
=======================================================

The ``PBC`` module offers utilities for distance computations using periodic
boundary conditions.

Minimal images
--------------

These functions take a vector and wrap it inside a :ref:`cell <type-UnitCell>`,
by finding the minimal vector fitting inside the cell.

.. function:: minimal_image(vect, cell::UnitCell)

    Wraps the ``vect`` vector inside the ``cell`` unit cell. `vect` can be a
    ``Vector`` (`i.e.` a 1D array), or a view from an :ref:`type-Array3D`. This
    function returns the wrapped vector.

.. function:: minimal_image!(vect, cell::UnitCell)

    Wraps ``vect`` inside of ``cell``, and stores the result in ``vect``.

.. function:: minimal_image!(A::Matrix, cell::UnitCell)

    If ``A`` is a 3xN Array, wraps each one of the columns in the ``cell``. The
    result is stored in ``A``. If ``A`` is not a 3xN array, this throws an error.

Distances
---------

Distances are computed using periodic boundary conditions, by wrapping the
:math:`\vec r_i - \vec r_j` vector in the cell before computing its norm.

Within one Frame
^^^^^^^^^^^^^^^^

This set of functions computes distances within one frame.

.. function:: distance(ref::Frame, i::Integer, j::Integer)

    Computes the distance between particles ``i`` and ``j`` in the frame.

.. function:: distance_array(ref::Frame [, result])

    Computes all the distances between particles in ``frame``. The ``result``
    array can be passed as a pre-allocated storage for the :math:`N\times N`
    distances matrix. ``result[i, j]`` will be the distance between the particle
    i and the particle j.

.. function:: distance3d(ref::Frame, i::Integer, j::Integer)

    Computes the :math:`\vec r_i - \vec r_j` vector and wraps it in the cell. This
    function returns a 3D vector.


Between two Frames
^^^^^^^^^^^^^^^^^^

This set of functions computes distances within two frames, either computing the
how much a single particle moved between two frames or the distance between the
position of a particle i in a reference frame and a particle j in a specific
configuration frame.

.. function:: distance(ref::Frame, conf::Frame, i::Integer, j::Integer)

    Computes the distance between the position of the particle i in ``ref``, and
    the position of the particle j in ``conf``

.. function:: distance(ref::Frame, conf::Frame, i::Integer)

    Computes the distance between the position of the same particle i in ``ref``
    and ``conf``.

.. function:: distance3d(ref::Frame, conf::Frame, i::Integer)

    Wraps the ``ref[i] - conf[i]`` vector in the ``ref`` unit cell.

.. function:: distance3d(ref::Frame, conf::Frame, i::Integer, j::Integer)

    Wraps the ``ref[i] - conf[i]`` vector in the ``ref`` unit cell.
