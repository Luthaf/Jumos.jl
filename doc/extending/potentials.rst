
Defining a new potential
========================

.. _user-potential:

User potential
--------------

The easier way to define a new potential is to create ``UserPotential`` instances,
providing potential and force functions. To add a potential, for example an harmonic
potential, we have to define two functions, a potential function and a force
function. These functions should take a ``Float64`` value (the distance) and
return a ``Float64`` (the value of the potential or the force at this distance).

.. function:: UserPotential(potential, force)

    Creates an UserPotential instance, using the ``potential`` and ``force``
    functions.

    ``potential`` and ``force`` should take a ``Float64`` parameter and return a
    ``Float64`` value.

.. function:: UserPotential(potential)

    Creates an UserPotential instance by automatically computing the force
    function using a finite difference method, as provided by the
    `Calculus <http://github.com/johnmyleswhite/Calculus.jl>`_ package.

Here is an example of the user potential usage:

.. code-block:: julia

    # potential function
    f(x) = 6*(x-3.)^2 - .5
    # force function
    g(x) = -12.*x + 36.

    # Create a potential instance
    my_harmonic_potential = UserPotential(f, g)

    # One can also create a potential whithout providing a funtion for the force,
    # at the cost of a less effective computation.
    my_harmonic_2 = UserPotential(f)

    force(my_harmonic_2, 3.3) == force(my_harmonic_potential, 3.3)
    # false

    isapprox(force(my_harmonic_2, 3.3), force(my_harmonic_potential, 3.3))
    # true


Subtyping PotentialFunction
---------------------------

A more efficient way to use custom potential is to subtype the either ``PairPotential``,
``BondedPotential``, ``AnglePotential`` or ``DihedralPotential``, according to
the new potential from.

For example, we are goning to define a Lennard-Jones potential using an other function:

.. math::

    V(r) = \frac{A}{r^{12}} - \frac{B}{r^{6}}

This is obviously a ``ShortRangePotential``, so we are going to subtype this potential
function.

To define a new potential, we need to add methods to two functions: `call` and
`force`. It is necessary to import these two functions in the current scope before
extending them. Potentials should be declared as ``immutable``, this allow for
optimizations in the code generation.

.. code-block:: julia

    # import the functions to extend
    import Base: call
    import Jumos: force

    immutable LennardJones2 <: PairPotential
        A::Float64
        B::Float64
    end

    # potential function
    function call(pot::LennardJones2, r::Real)
        return pot.A/(r^12) - pot.B/(r^6)
    end

    # force function
    function force(pot::LennardJones2, r::Real)
        return 12 * pot.A/(r^13) - 6 * pot.B/(r^7)
    end

The above example can the be used like this:

.. code-block:: julia

    # Add a LennardJones2 interaction to an universe
    universe = Universe(...)
    add_interaction!(universe, LennardJones2(4.5, 5.3), "He", "He")

    # Directly compute values
    pot = LennardJones2(4.5, 5.3)
    pot(3.3) # value of the potential at r=3.3
    force(pot, 8.12) # value of the force at r=8.12
