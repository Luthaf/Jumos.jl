Utilities
=========

This part of the documentation give some information about basic algebrical types
used in |Jumos|.

.. toctree::
    :maxdepth: 2

    units
    distances
    trajectories

.. _type-Array3D:

Array3D
-------

3-dimensionals vectors are very common in molecular simulations. The ``Array3D``
type implements arrays of this kind of vectors, provinding all the usual
operations between its components.

If ``A`` is an ``Array3D`` and ``i`` an integer, ``A[i]`` is a 3-dimensional
vector implementing ``+, -`` between vector, ``.+, .-, .*, */`` between vectors
and scalars; ``dot`` and ``cross`` products, and the ``unit!`` function,
normalizing its argument.
