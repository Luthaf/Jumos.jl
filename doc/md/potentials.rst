.. _potentials:

**********
Potentials
**********

In order to compute the energy or the forces acting on a particle, two informations
are needed : a potential energy function, and a computation algorithm. The potential
function is a description of the variations of the potential with the particles
positions, and a potential computation is a way to compute the values of this
potential function. The following image shows the all the potentials functions
currently implemented in |Jumos|.

.. image:: ../static/img/potentials.*
    :alt: Potential functions type hierarchy

We can see these potentials are classified as four main categories: pair potentials,
bond potentials, angles potentials (between 3 atoms) and dihedral potentials
(between 4 atoms).

The only implemented pair potentials are short-range potentials. Short-range
pair potentials go to zero faster than the :math:`1/r^3` function,
and long-range pair potentials go to zero at the same speed or more slowly than
:math:`1/r^3`. A typical example of long-range pair potential is the Coulomb
potential between charged particles.

Potential functions
===================

Short-range pair potential
--------------------------

Short-range pair potential are subtypes of `PairPotential`. They only depends on
the distance between the two particles they are acting on. They should have two
main properties:

- They should go to zero when the distance goes to infinity;
- They should go to zero faster than the :math:`1/r^3` function.

.. _lennard-jones-potential:

Lennard-Jones potential
^^^^^^^^^^^^^^^^^^^^^^^

A Lennard-Jones potential is defined by the following expression:

.. math::

    V(r) = 4\epsilon \left( \left( \frac{\sigma}{r} \right)^{12} -
                            \left( \frac{\sigma}{r} \right)^6 \right)

.. function:: LennardJones(epsilon, sigma)

    Creates a Lennard-Jones potential with :math:`\sigma = \text{sigma}`, and
    :math:`\epsilon = \text{epsilon}`. ``sigma`` should be in angstroms, and
    ``epsilon`` in :math:`kJ/mol`.

    Typical values for Argon are: :math:`\sigma = 3.35\ A, \epsilon = 0.96\ kJ/mol`

.. _null-potential:

Null potential
^^^^^^^^^^^^^^

This potential is a potential equal to zero everywhere. It can be used to define
"interactions" between non interacting particles.

.. function:: NullPotential()

    Creates a null potential instance.

Bonded potential
----------------

Bonded potentials acts between two particles, but does no go to zero with an
infinite distance. *A contrario*, they goes to infinity as the two particles
goes apart of the equilibirum distance.

Harmonic
^^^^^^^^

An harmonic potential have the following expression:

.. math::

    V(r) = \frac12 k (\vec r - \vec r_0)^2 - D_0

:math:`D_0` is the depth of the potential well.

.. function:: Harmonic(k, r0, depth=0.0)

    Creates an harmonic potential with a spring constant of `k` (in
    :math:`kJ.mol^{-1}.A^{-2}`), an equilibrium distance :math:`r_0` (in angstroms);
    and a well's depth of :math:`D_0` (in :math:`kJ/mol`).

Adding interactions to a simulation
===================================

Before runnning a simulation, we should define interactions between all the pairs
of atomic types. The ``add_interaction`` function should be used for that.

.. function:: add_interaction(sim, potential, atoms [, computation=:auto, kwargs...])

    Adds an interaction between the ``atoms`` in the simulation ``sim``. The
    energy and the forces for this interaction will be computed using the
    potential function ``potential``.

    ``atoms`` can be a string, an integer, or a tuple of strings and integers.
    The strings should be the atomic names, and the integers the atomic type in
    the simulation's topology. For example, if a simulation has the three
    following atomic types: ``["C", "H", "O"]`` with respective index 1, 2 and 3;
    then the atomic pair ``("H", "O")`` can be accessed with either ``(2, 3)``,
    ``(2, "O")``, ``("H", 3)`` or ``("H", "O")``.

    The keyword argument ``computation`` deternines which computation is used
    for the given potential function. The default is to use CutoffComputation
    with short-range pair potentials, and DirectComputation with the other ones.

    All the other keyword arguments will be used to create the potential
    computation algorithm.

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

This is obviously a ``PairPotential``, so we are going to subtype this potential
function.

To define a new potential, two functions are needed: `call` and `force`. It is
necessary to import these two functions in the current scope before extending them.
Potentials should be declared as ``immutable``, to allow some optimisations in
the computations.

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

    sim = MolecularDynamic(1.0)

    add_interaction(sim, LennardJones2(4.5, 5.3), ("He", "He"))

    pot = LennardJones2(4.5, 5.3)

    pot(3.3) # value of the potential at r=3.3
    force(pot, 3.3) # value of the force at r=3.3


Potential computation
=====================

As stated at the begiging of this potentials section, we need two informations to
compute interactions between particles: a potential function, and a potential
computation. The potential compuatation algorithms come in four flavors:

.. image:: ../static/img/computations.*
    :alt: Potential computation algorithm hierarchy

* The ``DirectComputation`` is only a small wrapper on the top of the potential
  functions, and directly calls the potential function methods for energy and
  force evaluations.
* The ``CutoffComputation`` is used for short range potentials. All interactions
  at a longer distance than the cutoff distance are set to zero. The default cutoff
  is :math:`12\ A`, and this can be changed by passing a ``cutoff`` keyword argument
  to the ``add_interaction`` function. With this computation, the energy is shifted
  so that their is a continuity in the energy at the cutoff distance.
* The ``TableComputation`` use table lookup to extrapolate the potential energy
  and the forces at a given point. This saves computation time at the cost of
  accuracy. This algorithm is parametrized by an integer, the size of the
  undelying array. Increases in this size will result in more accuracy, at the
  cost of more memory usage. The default size is 2000 points — which corresponds
  to roughly 15kb. ``TableComputation`` has also a maximum distance for computations,
  ``rmax``. For any bigger distances, the ``TableComputation`` will returns a
  null energy and null forces. So ``TableComputation`` can only be used if you
  are sure that the particles will never be at a greater distance than ``rmax``.
* The ``LongRangeComputation`` is not implemented yet.

Which computation for which potential ?
---------------------------------------

Not all computation algorithms are suitable for all potential functions. The usable
associations are in the table below.

+----------------------+-------------------+-------------------+------------------+
|    Function          | DirectComputation | CutoffComputation | TableComputation |
+======================+===================+===================+==================+
| ShortRangePotential  |  |yes|            |  |yes|            |  |yes|           |
+----------------------+-------------------+-------------------+------------------+
| BondedPotential      |  |yes|            |  |no|             |  |yes|           |
+----------------------+-------------------+-------------------+------------------+
| AnglePotential       |  |yes|            |  |no|             |  |yes|           |
+----------------------+-------------------+-------------------+------------------+
| DihedralPotential    |  |yes|            |  |no|             |  |yes|           |
+----------------------+-------------------+-------------------+------------------+

.. |yes| image:: ../static/img/yes.png
    :alt: Yes
    :width: 16px
    :height: 16px

.. |no| image:: ../static/img/no.png
    :alt: No
    :width: 16px
    :height: 16px

Using non-default computation
-----------------------------

By default, the computation algorithm is automatically determined by the potential
function type. ``ShortRangePotential`` are computed with ``CutoffComputation``,
and all other potentials are computed by ``DirectComputation``. If we want to use
another computation algorithm, this can be done by providing a ``computation``
keyword to the ``add_interaction`` function. The following values are allowed:

* ``:direct`` to use a ``DirectComputation``;
* ``:cutoff``  to use a ``CutoffComputation``. The cutoff can be specified with
  the ``cutoff`` keyword argument;
* ``:table``` to use a ``TableComputation``. The table size can be specified with
  the ``numpoints`` keyword argument, and the maximum distance with the ``rmax``
  keyword argument.

Here is an example of how we can use these keywords.

.. code-block:: julia

    sim = MolecularDynamic(1.0) # Creating a simulation

    # ...

    # Use default computation, i.e. CutoffComputation with 12A cutoff.
    add_interaction(sim, LennardJones(0.4, 3.3))

    # Use another cutoff distance
    add_interaction(sim, LennardJones(0.4, 3.3), cutoff=7.5)

    # Use direct computation
    add_interaction(sim, LennardJones(0.4, 3.3), computation=:direct)

    # Use table computation with 3000 points, and a maximum distance of 10A
    add_interaction(sim, LennardJones(0.4, 3.3),
                    computation=:table, numpoints=3000, rmax=10.0)
