.. _simulation-usage:

Usage example
=============

With `Jumos`, you run simulations by writting Julia scripts. You don't need to
know much of Julia, and if you already have programmed with C++ or Python it should
feel familiar. Just remember that array index start at 1, not 0. If you come from
FORTRAN, the main point will be that you can access composit types fields using the
the dot notation : ``foo.bar = 3`` will set the ``bar`` field of ``foo`` to 3.

Lennard-Jones fluid
-------------------

Here is a simple simulation script for running a simulation of a Lennard-Jones
fluid at :math:`300K`.

.. literalinclude:: /../examples/lennard-jones.jl
   :language: julia
   :linenos:

Each simulation script should start by the ``using Jumos`` directive. This imports
the module and the exported names in the current scope.

Then, in this script, we create a molecular dynamics (``"MD"``) simulation with
a timestep of :math:`1.0\ \text{fs}`, and associated a cubic cell to the simulation.
The topology and the original positions are read from the same file, as
an :file:`.xyz` file contains topological information (mainly the atomics names).

The only interaction — a :ref:`Lennard-Jones <lennard-jones-potential>`
interaction — is also added to the simulation before the run. The next lines add
some outputs to the simulation, namely a :ref:`trajectory <trajectory-output>`
and an :ref:`energy <energy-output>` output. And finally the simulation is
started for a first 500 steps.

Any parameter can easily be changed during the simulation: here, at the line 27,
we change the output frequency of the trajectory output, and then run the
simulation for another 5000 steps.
