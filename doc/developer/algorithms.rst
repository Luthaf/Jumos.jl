Developping new algorithms
==========================

.. TODO:: How to subtype and extend functions


Writing a new :ref:`integrator <simulation-integrator>`
-------------------------------------------------------

To create a new integrator, you have to subtype the ``BaseIntegrator`` type, and
provide the ``call`` method, with the following signature:
``call(::BaseIntegrator, ::MolecularDynamic)``.

The integrator is responsible for calling the ``get_forces!(::MolecularDynamic)``
function if it need the ``MolecularDynamic.forces`` field to be updated. It should
update the two :ref:`Array3D <type-Array3D>`: ``MolecularDynamic.frame.positions``
and ``MolecularDynamic.frame.velocities`` with appropriate values.

The ``MolecularDynamic.masses`` field is a ``Vector{Float64}`` containing the particles
masses, in the same order than in the current simulation :ref:`frame <type-Frame>`.
Any other required information should be stored in the new ``BaseIntegrator`` subtype.

Computing the forces
--------------------

.. _type-NaiveForceComputer:

Naive force computation
^^^^^^^^^^^^^^^^^^^^^^^

The ``NaiveForceComputer`` algorithm computes the forces by iterating over all the
pairs of atoms, and calling the appropriate interaction potential. This algorithm
is the default in `Jumos`.

New algorithm for forces computations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a new force computation algorithm, you have to subtype ``BaseForcesComputer``,
and provide the method ``call(::BaseForcesComputer, forces::Array3D, frame::Frame,
interactions)``.

This method should fill the forces array with the forces acting on each particles:
``forces[i]`` should be the 3D vector of forces acting on the atom ``i``. In order
to do this, the algorithm can use the ``frame.posistions`` and ``frame.velocities``.
``interactions`` is a dictionary associating tuples of integers (the atoms types)
to :ref:`potential <potentials>`. The ``get_potential`` function can be useful
to get a the potential function acting on two particles.

.. function:: get_potential(interactions, topology, i, j)

    Returns the potential between the atom i and the atom j in the topology.

Due to the internal unit system, forces returned by the potentials are in
:math:`kJ/(mol \cdot A)`, and should be in :math:`uma \cdot A / fs^2` for being
used with the newton equations.  The conversion can be handled by the unexported
``Simulations.force_array_to_internal!`` function, converting the values of an
Array3D from :math:`kJ/(mol \cdot A)` to :math:`uma \cdot A / fs^2`.

Adding a new :ref:`check <simulation-checks>`
---------------------------------------------

Adding a new check algorithm is as simple as subtyping ``BaseCheck`` and extending
the ``call(::BaseCheck, ::MolecularDynamic)`` method. This method should throw an
exception of type ``CheckError`` if the checked condition is not fullfiled.

.. jl:type:: CheckError

    Customs exception providing a specific error message for simulation checking.

    .. code-block:: jlcon

        julia> throw(CheckError("This is a message"))
        ERROR: Error in simulation :
        This is a message
        in __text at no file (repeats 3 times)

Adding new :ref:`controls <simulation-controls>`
------------------------------------------------

To add a new type of control to a simulation, the main way is to subtype
``BaseControl``, and provide two specialised methods: ``call(::BaseControl,
::MolecularDynamic)`` and the optional ``setup(::BaseControl, ::MolecularDynamic)``.
The ``call`` method should contain the algorithm inplementation, and the ``setup``
method is called once at each simulation start. It should be used to add add some
:ref:`computation algorithm <simulation-computes>` to the simulation.


Computing values
----------------------

To add a new compute algorithm (``MyCompute``), we have to subtype ``BaseCompute``
and provide specialised implementation for the ``call`` function; with the
following signature:

.. function:: call(::MyCompute, ::MolecularDynamic)

    This function can set a ``MolecularDynamic.data`` entry with any kind of key
    to store the computed value.

.. _new-output:

Outputing values
----------------

An other way to create a custom output is to subtype ``BaseOutput``. The subtyped
type must have two integer fields: ``current`` and ``frequency``, and the constructor
should initialize ``current`` to 0. The ``write`` function should also be overloaded
for the signature ``write(::BaseOutput, ::Dict)``. The dictionairy parameter
contains all the values set up by the :ref:`computation algorithms <simulation-computes>`,
and a special key ``:frame`` refering to the current simulation :ref:`frame <type-Frame>`.

``BaseOutput`` subtypes can also define a ``setup(::BaseOutput, ::MolecularDynamic)``
function to do some setup job, like adding the needed computations to the
simulation.

As an example, let's build a custom output writing the ``x`` position of the
first atom of the simulation at each step. This position will be taken from the
frame, so no specific computation algorithm is needed here. But this position
will be writen in bohr, so some conversion from Angstroms will be needed.

.. code-block:: julia

    # File FirstX.jl

    using Jumos

    import Base.write
    import Jumos.setup

    type FirstX <: BaseOutput
        file::IOStream
        current::Integer
        frequency::Integer
    end

    # Default values constructor
    function FirstX(filename, frequency=1)
        file = open(filename, "w")
        return FirstX(file, 0, frequency)
    end

    function write(out::FirstX, context::Dict)
        frame = context[:frame]
        x = frame.positions[1][1]
        x = x/0.529 # Converting to bohr
        write(out.file, "$x \n")
    end

    # Not needed here
    # function setup(::FirstX, ::MolecularDynamic)

This type can be used like this:

.. code-block:: julia

    using Jumos
    require("FirstX.jl")

    sim = MolecularDynamic(1.0)
    # ...

    add_output(sim, FirstX("The-first-x-file.dat"))
