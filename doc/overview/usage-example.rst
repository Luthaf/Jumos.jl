.. _simulation-usage:

Usage example
=============

In `Jumos`, one run simulations by writting specials Julia scripts. A primer
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

Then, in this script, we create a molecular dynamics simulation with a timestep
of :math:`1.0\ \text{fs}`, and associated a cubic cell to this simulation.
The topology and the original positions are read from the same file, as
an :file:`.xyz` file contains topological information (mainly the atomics names).

The only interaction — a :ref:`Lennard-Jones <lennard-jones-potential>`
interaction — is also added to the simulation before the run. The next lines add
some outputs to the simulation, namely a :ref:`trajectory <trajectory-output>`
and an :ref:`energy <energy-output>` output. Finally, the simulation runs for a
first 500 steps.

Any parameter can easily be changed during the simulation: here, at the line 25,
we change the output frequency of the trajectory output, and then run the
simulation for another 5000 steps.
