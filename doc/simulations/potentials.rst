**********
Potentials
**********

Existing potentials
===================

In molecular simulations, there is two main kind of potential : short-range
potential and long-range potential. Short-range potential goes to zero faster
than the :math:`1/r` function, and long-range potentials goes to zero at the
same speed or slower than :math:`1/r`. Typical long-range potential is the
Coulomb potential between charged paricles.

For now, Jumos only implement computations on short-range pair potentials, using a
cuttoff distance.

Short-range potentials
----------------------

Cuttoff distance
^^^^^^^^^^^^^^^^

TODO

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

    Typical values are for Argon: :math:`\sigma = 3.0, \epsilon = 0.21`
    TODO: Check these values on Wiki

.. _null-potential:

Null potential
^^^^^^^^^^^^^^

This potential is a potential equal to zero everywhere. It can be used to define
interactions between non interacting particles.

.. function:: NullPotential()

    Creates a null potential instance.


Adding interactions to a simulation
===================================

.. function:: add_interaction(...)

    TODO


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

Here is an example of user potential usage:

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

TODO

Example: LJ second form.

Attention : unit system

.. TODO : LongRangePotential
