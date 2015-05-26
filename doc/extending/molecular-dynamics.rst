Algorithms for molecular dynamics
=================================

Writing a new :ref:`integrator <type-Integrator>`
-------------------------------------------------------

To create a new integrator, you have to subtype the ``Integrator`` type, and
provide the ``call`` method, with the following signature:
``call(::Integrator, ::MolecularDynamic)``.

The integrator is responsible for calling the ``getforces!(::MolecularDynamics,
::Universe)`` function when the ``MolecularDynamics.forces`` field needs to be
updated. It should update the two :ref:`Array3D <type-Array3D>`:
``Universe.frame.positions`` and ``Universe.frame.velocities`` with appropriate
values.

The ``Universe.masses`` field is a ``Vector{Float64}`` containing the particles
masses. Any other required information should be stored in the new ``Integrator``
subtype.

Computing the forces
--------------------

To create a new force computation algorithm, you have to subtype ``ForcesComputer``,
and provide the method ``call(::ForcesComputer, ::Universe, forces::Array3D)``.

This method should fill the forces array with the forces acting on each particles:
``forces[i]`` should be the 3D vector of forces acting on the atom ``i``. In order to
do this, the algorithm can use the ``Universe.frame.posistions`` and
``Universe.frame.velocities`` arrays.

Potentials to use for the atoms can be optained throught the following functions:

.. function:: pairs(::Interactions, i, j)

    Get a ``Vector{PairPotential}`` of interactions betweens atoms ``i`` and ``j``.

.. function:: bonds(::Interactions, i, j)

    Get a ``Vector{BondPotential}`` of interactions betweens atoms ``i`` and ``j``.

.. function:: angles(::Interactions, i, j, k)

    Get a ``Vector{AnglePotential}`` of interactions betweens atoms ``i`` and ``j``
    and ``k``.

.. function:: dihedrals(::Interactions, i, j, k, m)

    Get a ``Vector{DihedralPotential}`` of interactions betweens atoms ``i``, ``j``,
    ``k`` and ``m``.

Adding new :ref:`checks <type-check>`
-------------------------------------

Adding a new check algorithm is as simple as subtyping ``Check`` and extending the
``call(::Check, ::Universe, ::MolecularDynamic)`` method. This method should throw an
exception of type ``CheckError`` if the checked condition is not fullfiled.

.. jl:type:: CheckError

    Customs exception providing a specific error message for simulation checking.

    .. code-block:: jlcon

        julia> throw(CheckError("This is a message"))
        ERROR: Error in simulation :
        This is a message
        in __text at no file (repeats 3 times)

Adding new :ref:`controls <type-control>`
-----------------------------------------

To add a new type of control to a simulation, the main way is to subtype ``Control``,
and provide two specialised methods: ``call(::Control, ::Universe)`` and the optional
``setup(::Control, ::Simulation)``. The ``call`` method should contain the algorithm
inplementation, and the ``setup`` method is called once at each simulation start. It
should be used to add add some :ref:`computation algorithm <type-compute>` to the
simulation, as needed.
