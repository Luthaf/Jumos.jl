Jumos: customisable molecular simulation package
================================================

|Jumos| is a package for molecular simulations written using the `Julia`_ language.
It provides a set of customisable blocks for running molecular simulations, and
developing novel algorithm for each part of a simulation. Every algorithm (potential
computation, long range interactions, pair lists computing, outputs, *etc.*) can
easily be customised.

.. _Julia : http://julialang.org/

.. note::
    This package is in a very alpha stage, and still in heavy developement.
    Breaking changes can occurs in the API without any notice at any time.

This documentation is divided in two parts: first come the user manual, starting
by some explanation about usal :ref:`algorithms in simulations <simulation-steps>`
and an :ref:`example <simulation-usage>` of how we can use |Jumos| to run a
molecular dynamic simulation. The second part is the developer documentation,
exposing the internal of |Jumos|, and how we can use them to programm new
algorithms.

Installation
------------

|Jumos| uses the 0.4 prerelease version of `Julia`_, and can be installed at julia
prompt with the ``Pkg.add("Jumos")`` command. You also can run the unit tests with
the ``Pkg.test("Jumos")`` command.

User manual
-----------

.. toctree::
    :maxdepth: 2

    overview/index
    universe/index
    simulations/index
    utils/index

Extending |Jumos|
-----------------

.. toctree::
    :maxdepth: 2

    extending/index
