.. _potentials:

**********
Potentials
**********

In order to compute the energy or the forces acting on a particle, two informations
are needed : a potential energy function, and a computation algorithm. The potential
function is a description of the variations of the potential with the particles
positions, and a potential computation is a way to compute the values of this
potential function. The following image shows the all the potentials functions types
currently available in |Jumos|.

.. image:: ../_static_/img/potentials.*
    :alt: Potential functions type hierarchy

We can see these potentials are classified as four main categories: pair potentials,
bond potentials, angles potentials (between 3 atoms) and dihedral potentials
(between 4 atoms).

The only implemented pair potentials are short-range potentials. Short-range
pair potentials go to zero faster than the :math:`1/r^3` function,
and long-range pair potentials go to zero at the same speed or more slowly than
:math:`1/r^3`. A typical example of long-range pair potential is the Coulomb
potential between charged particles.

.. _type-PotentialFunction:

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

.. _type-PotentialComputation:

Potential computation
=====================

As stated at the begiging of this section, we need two informations to compute
interactions between particles: a potential function, and a potential computation.
The potential compuatation algorithms come in four flavors:

.. image:: ../_static_/img/computations.*
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

.. |yes| image:: ../_static_/img/yes.png
    :alt: Yes
    :width: 16px
    :height: 16px

.. |no| image:: ../_static_/img/no.png
    :alt: No
    :width: 16px
    :height: 16px
