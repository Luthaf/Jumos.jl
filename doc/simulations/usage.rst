Usage example
=============

With `Jumos`, you run simulations by writting Julia scripts. You don't need to
know much of Julia, and if you already have done some C++ or Python you should
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

TODO : defaults values in simulation


Overwrite the algorithm
-----------------------
