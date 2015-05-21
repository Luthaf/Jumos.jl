.. _type-UnitCell:

UnitCell
========

A simulation cell (``UnitCell`` type) is the virtual container in which all the
particles of a simulation move. The UnitCell type is parametrized by the
``celltype``. There are three different types of simulation cells:

* Infinite cells (``InfiniteCell``) do not have any boundaries. Any move
  is allowed inside these cells;
* Orthorombic cells (``OrthorombicCell``) have up to three independent lenghts;
  all the angles of the cell are set to 90° (:math:`\pi/2` radians)
* Triclinic cells (``TriclinicCell``) have 6 independent parameters: 3 lenghts and
  3 angles.

Creating simulation cell
------------------------

.. function:: UnitCell(A, [B, C, alpha, beta, gamma, celltype])

    Creates an unit cell. If no ``celltype`` parameter is given, this function tries
    to guess the cell type using the following behavior: if all the angles are
    equals to :math:`\pi/2`, then the cell is an ``OrthorombicCell``; else, it
    is a ``TriclinicCell``.

    If no value is given for ``alpha, beta, gamma``, they are set to :math:`\pi/2`.
    If no value is given for ``B, C``, they are set to be equal to ``A``.
    This creates a cubic cell. If no value is given for ``A``, a cell with lenghts
    of 0 Angström and :math:`\pi/2` angles is constructed.

    .. code-block:: jlcon

        julia> UnitCell() # Without parameters
        OrthorombicCell
            Lenghts: 0.0, 0.0, 0.0

        julia> UnitCell(10.) # With one lenght
        OrthorombicCell
            Lenghts: 10.0, 10.0, 10.0

        julia> UnitCell(10., 12, 15) # With three lenghts
        OrthorombicCell
            Lenghts: 10.0, 12.0, 15.0

        julia> UnitCell(10, 10, 10, pi/2, pi/3, pi/5) # With lenghts and angles
        TriclinicCell
            Lenghts: 10.0, 10.0, 10.0
            Angles: 1.5707963267948966, 1.0471975511965976, 0.6283185307179586

        julia> UnitCell(InfiniteCell) # With type
        InfiniteCell

        julia> UnitCell(10., 12, 15, TriclinicCell) # with lenghts and type
        TriclinicCell
            Lenghts: 10.0, 12.0, 15.0
            Angles: 1.5707963267948966, 1.5707963267948966, 1.5707963267948966

.. function:: UnitCell(u::Vector, [v::Vector, celltype])

    If the size matches, this function expands the vectors and returns the
    corresponding cell.

    .. code-block:: jlcon

        julia> u = [10, 20, 30]
        3-element Array{Int64,1}:
         10
         20
         30

        julia> UnitCell(u)
        OrthorombicCell
            Lenghts: 10.0, 20.0, 30.0

Indexing simulation cell
------------------------

You can access the cell size and angles either directly, or by integer indexing.

.. function:: getindex(b::UnitCell, i::Int)

    Calling ``b[i]`` will return the corresponding length or angle : for ``i in
    [1:3]``, you get the ``i``:superscript:`th` lenght, and for ``i in [4:6]``,
    you get [avoid get] the angles.

    In case of intense use of such indexing, direct field access should be
    more efficient. The internal fields of a cell are : the three lenghts
    ``a, b, c``, and the three angles ``alpha, beta, gamma``.

Boundary conditions and cells
-----------------------------

Only fully periodic boundary conditions are implemented for now. This means that
if a particle crosses the boundary at some step, it will be wrapped up and will
appear at the opposite boundary.

Distances and cells
-------------------

The distance between two particles depends on the cell type. In all cases, the
minimal image convention is used: the distance between two particles is the
minimal distance between all the images of theses particles. This is explicited
in the :ref:`distances` part of this documentation.
