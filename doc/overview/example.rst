.. _simulation-usage:

Simulation example
==================

In |Jumos|, one run simulations by writting specials Julia scripts. A primer
intoduction to the Julia language can be found `here <http://learnxinyminutes.com/docs/julia/>`_,
if needed.

Lennard-Jones fluid
-------------------

Here is a simple simulation script for running a simulation of a Lennard-Jones
fluid at :math:`300K`.

.. literalinclude:: /../examples/lennard-jones.jl
   :language: julia
   :linenos:

Each simulation script should start by the ``using Jumos`` directive. This imports
the module and the exported names in the current scope.

Then, in this script, we create two main objects: a :ref:`simulation
<Type-Simulation>`, and an :ref:`universe <Type-Universe>`. The topology and the
original positions for the universe are read from the same file, as an :file:`.xyz`
file contains topological information (mainly the atomics names) and coordinates. The
velocities are then initialized from a Boltzmann distribution at 300K.

The only interaction — a :ref:`Lennard-Jones <lennard-jones-potential>`
interaction — is also added to the universe before the run. The next lines add
some outputs to the simulation, namely a :ref:`trajectory <type-TrajectoryOutput>`
and an :ref:`energy <type-EnergyOutput>` output. Finally, the simulation runs for
5000 steps.

Other example
-------------

Some other examples scripts can be found in the example folder in Jumos' source
tree. To go there, use the julia prompt:

.. code-block:: julia

    julia> Pkg.dir("Jumos")
    "~/.julia/v0.4/Jumos"

    julia>; cd $ans/examples
    ~/.julia/v0.4/Jumos/examples
