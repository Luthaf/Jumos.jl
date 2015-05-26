Algorithms for all simulations
==============================

Computing values
----------------

Algorithms to compute properties from a simulation are called ``Compute`` in |Jumos|.
They all act by taking an :ref:`Universe <type-Universe>` as parameter, and then
setting a value in the ``Universe.data`` dictionary.

To add a new compute algorithm (we will call it ``MyCompute``), we have to subtype
``Jumos.Simulations.BaseCompute`` and provide specialised implementation for the
``Base.call`` function; with the following signature:

.. function:: Base.call(::Compute, ::Universe)
    :noindex:

    This function can set a ``Universe.data`` entry with a ``Symbol`` key to store
    the computed value. This value can be anything, but basic types (scalars, arrays,
    *etc.*) are to be prefered.

.. _new-output:

Outputing values
----------------

An other way to create a custom output is to subtype ``Output``. The subtyped type
must have at least one field: ``frequency::OutputFrequency``, which is responsible
for selecting the write frequency of this output. Two functions can be overloaded
to set the output behaviour.

.. function:: Base.write(::Output, context::Dict{Symbol, Any})
    :noindex:

    Write the ouptut. This function will be called  every ``n`` simulation steps
    according to the ``frequency`` field.

    The ``context`` parameter contains all the values set up by the
    :ref:`computation algorithms <type-Compute>`, and a special key ``:frame``
    refering to the current simulation :ref:`frame <type-Frame>`.

.. function:: Jumos.setup(::Output, ::Simulation)

    This function is called once, at the begining of a simulation run. It should do
    some setup job, like adding the needed computations algorithms to the simulation.

As an example, let's build a custom output writing the ``x`` position of the first
atom of the simulation at each step. This position will be taken from the frame, so
no specific computation algorithm is needed here. But this position will be writen in
bohr, so some conversion from Angstroms will be needed.

.. code-block:: julia

    # File FirstX.jl

    using Jumos

    import Base.write
    import Jumos.setup

    type FirstX <: Output
        file::IOStream
        frequency::OutputFrequency
    end

    # Default values constructor
    function FirstX(filename, frequency=1)
        file = open(filename, "w")
        return FirstX(file, OutputFrequency(frequency))
    end

    function write(out::FirstX, context::Dict)
        frame = context[:frame]
        x = frame.positions[1][1]
        x = x/0.529 # Converting to bohr
        write(out.file, "$x \n")
    end

    # Not needed here
    # function setup(::FirstX, ::Simulation)

This type can be used like this:

.. code-block:: julia

    using Jumos
    require("FirstX.jl")

    sim = Simulation(:md, 1.0)
    # ...

    push!(sim, FirstX("The-first-x-file.dat"))
