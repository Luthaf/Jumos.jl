**********
Potentials
**********

.. _potentials:

Existing potentials
===================

In molecular simulations, there is two main kind of potential : short-range
potential and long-range potential. Short-range potential goes to zero faster
than the :math:`1/r^3` function, and long-range potentials goes to zero at the
same speed or slower than :math:`1/r^3`. Typical long-range potential is the
Coulomb potential between charged paricles.

For now, `Jumos` only implement computations on short-range pair potentials, using a
cutoff distance.

Short-range potentials
----------------------

Cuttoff distance
^^^^^^^^^^^^^^^^

Short range potentials are computed using a cutoff distance. This mean that all
interactions at a longer distance are set to be zero. The default distance
is :math:`12\ A`, and this can be changed by passing a ``cutoff`` keyword argument
to the ``Potential`` constructor, or to the ``add_interaction`` function.

.. _lennard-jones-potential:

Lennard-Jones potential
^^^^^^^^^^^^^^^^^^^^^^^

A Lennard-Jones potential is defined by the following expression :

.. math::

    V(r) = 4\epsilon \left( \left( \frac{\sigma}{r} \right)^{12} -
                            \left( \frac{\sigma}{r} \right)^6 \right)

.. function:: LennardJones(epsilon, sigma)

    Creates a Lennard-Jones potential with :math:`\sigma = \text{sigma}`, and
    :math:`\epsilon = \text{epsilon}`.

    Typical values for Argon are: :math:`\sigma = 3.35\ A, \epsilon = 0.96\ kJ/mol`

.. _null-potential:

Null potential
^^^^^^^^^^^^^^

This potential is a potential equal to zero everywhere. It can be used to define
"interactions" between non interacting particles.

.. function:: NullPotential()

    Creates a null potential instance.


Adding interactions to a simulation
===================================

Before runnning a simulation, one should define interactions between all the pairs
of atomic types. The ``add_interaction`` function can be used for that.

.. function:: add_interaction(::MDSimulation, potential, atoms [, cutoff=12.0])

    Add an interaction between the ``atoms`` in the simulation. The energy and
    the forces for this interaction will be computed using the given ``potential``.

    ``atoms`` can be a string, an integer, or a tuple of strings and integers.
    The strings should be the atomic names, and the integers the positions of
    the atomic type in the simulation's topology.


Defining a new potential
========================

.. _user-potential:

User potential
--------------

The easier way to define a new potential is to create ``UserPotential`` instances,
providing potential and force functions. To add a potential, let's say an harmonic
potential, one have to define two functions, a potential function and a force
function. These functions should take a ``Float64`` value (the distance) and
return a ``Float64`` (the value of the potential or the force at this distance).

.. function:: UserPotential(potential, force)

    Creates an UserPotential instance, using the ``potential`` and ``force`` functions.

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


Subtyping ShortRangePotential
-----------------------------

A better way to use custom potentials in a `Jumos` simulation would be to subtype
``ShortRangePotential``. Here is an example, defining a Lennard-Jones potential using
the second form:

.. math::

    V(r) = \frac{A}{r^{12}} - \frac{B}{r^{6}}

.. code-block:: julia

    # import the functions to extend
    import Base: call
    import Jumos: force

    type LennardJones2 <: ShortRangePotential
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

To define a new potential, two functions are needed: `call` and `force`. It is
necessary to import these two function in the current scope before extending them.
The above example can the be use like this:

.. code-block:: julia

    sim = Simulation("MD", 1.0)

    add_interaction(sim, LennardJones2(4.5, 5.3), ("He", "He"))

    pot = LennardJones2(4.5, 5.3)

    pot(3.3) # value of the potential at r=3.3
    force(pot, 3.3) # value of the force at r=3.3


.. TODO : LongRangePotential
