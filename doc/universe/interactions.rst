.. _type-interactions:

Interactions
============

The interaction type contains informations about which :ref:`potentials <potentials>`
the simulation should use for the atoms in the system. This type is not intended to
be manupulated directly, but rather through the :func:`add_interaction!` function.

.. function:: add_interaction!(universe, potential, atoms...[; computation=:auto; kwargs...])

    Add an interaction between the ``atoms`` atomic types, using the ``potential``
    :ref:`potential function <type-PotentialFunction>` in the ``universe``.

    This function accept many keywords arguments to tweak the
    :ref:`potential computation methode <type-PotentialComputation>` used to
    effectively compute the potential. The main keyword is ``computation`` which
    default to ``:auto``. It can be set to other values to choose another computation
    method than the default one.

    .. code-block:: jlcon

        julia> # Setup an universe with four atoms: two He and one Ar
        julia> top = Topology();

        julia> add_atom!(top, Atom("He")); add_atom!(top, Atom("He"));

        julia> add_atom!(top, Atom("Ar")); add_atom!(top, Atom("Ar"));

        julia> universe = Universe(UnitCell(), top);

        # Use default values for everything
        julia> add_interaction!(universe, LennardJones(0.23, 2.2), "He", "He")

        # Set the cutoff to 7.5 A
        julia> add_interaction!(universe, LennardJones(0.3, 2.5), "He", "Ar", cutoff=7.5)

        # Use table computation with 3000 points, and a maximum distance of 5A
        julia> add_interaction!(universe, Harmonic(40, 3.3), "Ar", "Ar", computation=:table, numpoints=3000, rmax=5.0)


Using non-default computation
-----------------------------

By default, the computation algorithm is automatically determined by the potential
function type. ``ShortRangePotential`` are computed with ``CutoffComputation``, and
all other potentials are computed by ``DirectComputation``. If we want to use another
computation algorithm, this can be done by providing a ``computation`` keyword to the
``add_interaction!`` function. The following values are allowed:

* ``:direct`` to use a ``DirectComputation``;
* ``:cutoff``  to use a ``CutoffComputation``. The cutoff can be specified with
  the ``cutoff`` keyword argument;
* ``:table``` to use a ``TableComputation``. The table size can be specified with
  the ``numpoints`` keyword argument, and the maximum distance with the ``rmax``
  keyword argument.
