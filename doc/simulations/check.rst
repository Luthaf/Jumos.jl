.. _simulation-checks:

Checking the simulation consistency
===================================

Molecular dynamic is usually a `garbage in, garbage out` set of algorithm. The
numeric and physical issues are not caught by the algorithm themselves, and the
physical (and chemical) consistency of the simulation should be checked often.

In `Jumos`, this is achieved by the ``Check`` algorithms, presented here. All the
type names defines what is checked by the algorithm. Checks can be added to a
simulation by using the ``add_check`` function.

.. function:: add_check(::MolecularDynamic, check)
    :noindex:

    Add a check to the simulation check list. If the check is already present,
    a warning is issued.

    Usage example:

    .. code-block:: julia

        sim = MolecularDynamic()

        # Note the parentheses, needed to instanciate the new check.
        add_check(sim, AllPositionsAreDefined())

Existing checks
---------------

.. cpp:type:: GlobalVelocityIsNull

    This algorithm checks if the global velocity (the total moment of inertia) is
    null for the current simulation. The absolute tolerance is :math:`10^{-5}\ A/fs`.

.. cpp:type:: TotalForceIsNull

    This algorithm checks if the sum of the forces is null for the current
    simulation. The absolute tolerance is :math:`10^{-5}\ uma \cdot A/fs^2`.

.. _type-AllPositionsAreDefined:

.. cpp:type:: AllPositionsAreDefined

    This algorithm check is all the positions and all the velocities are defined
    numbers, *i.e.* if all the values are not infinity or the ``NaN`` (not a number)
    values.

    This algorithm is used by default by all the molecular dynamic simulation.

Adding a new check
------------------

Adding a new check algorithm is as simple as subtyping ``BaseCheck`` and extending
the ``call(::BaseCheck, ::MolecularDynamic)`` method. This method should throw an
exception of type ``CheckError`` if the checked condition is not fullfiled.

.. cpp:type:: CheckError

    Custom exception providing a specific error message for simulation checking.

    .. code-block:: jlcon

        julia> throw(CheckError("This is a message"))
        ERROR: Error in simulation :
        This is a message
        in __text at no file (repeats 3 times)
