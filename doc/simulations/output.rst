.. _simulation-outputs:

Exporting values of interest
============================

While running a simulation, some basic analysis can be performed and writen to
a data file. Further analysis can be differed by writing the trajectory to a
file, and running existing tools on these trajectories.

In `Jumos`, outputs are subtypes of the ``BaseOutput`` type, and can be added to
a simulation by using the ``add_output`` function.

.. function:: add_output(sim, output)
    :noindex:

    Add an output to the simulation. If the output is already present, a warning
    is issued. Usage example:

    .. code-block:: julia

        sim = MolecularDynamic(1.0)

        # Direct addition
        add_output(sim, TrajectoryOutput("mytraj.xyz"))

        # Binding to a variable
        out = TrajectoryOutput("mytraj-2.xyz", 5)
        add_output(sim, out)

Each output is by default writen to its file at every simulation step. To speed-up
the simulation run and remove useless information, a *write frequency* can be used
as the last parameter of each output constructor. If this frequency is set to ``n``,
the values will be writen only every *n* simulaton steps. This frequency can also
be changed dynamically:

.. code-block:: julia

    # Frequency is set to 1 by default
    traj_out = TrajectoryOutput("mytraj.xyz")

    add_output(sim, traj_out)
    run!(sim, 300) # 300 steps will be writen

    # Set frequency to 50
    traj_out.frequency = 50
    run!(sim, 500) # 10 steps will be writen

Existing outputs
----------------

.. _trajectory-output:

Trajectory output
^^^^^^^^^^^^^^^^^

The first think one might want to save in a simulation run is the trajectory of
the system. Such trajectory can be used for visualisation, storage and further
analysis. The ``TrajectoryOutput`` provide a way to write this trajectory to a
file.

.. function:: TrajectoryOutput(filename, [frequency])

    This construct a ``TrajectoryOutput`` which can be used to write a trajectory
    to a file. The trajectory format is guessed from the ``filename`` extension.
    This format must have write capacities, see :ref:`the list <trajectory-formats>`
    of supported formats in `Jumos`.

.. _energy-output:

Energy output
^^^^^^^^^^^^^

The energy output write to a file the values of energy and temperature for the
current step of the simulation. Values writen are the current step, the kinetic
energy, the potential energy, the total energy and the temperature.

Defining a new output
---------------------

Adding a new output with custom values, can be done either by using a custom output
or by subtyping the ``BaseOutput`` type to define a new output. The the former way
is to be prefered when adding a *one-shot* output, and the latter when adding an
output which will be re-used.

Custom output
^^^^^^^^^^^^^

The ``CustomOutput`` type provide a way to build specific output. The data to be
writen should be :ref:`computed <simulation-computes>` before the output by adding
the specific algorithms to the current simulation. These computation algorithm
set a value in the ``MolecularDynamic.data`` dictionairy, which can be accessed
during the output step. See the :ref:`computation algorithms <simulation-computes>`
page for a list of keys.

.. function:: CustomOutput(filename, values, [frequency; header="# header string"])

    This create a ``CustomOutput`` to be writen to the file ``filename``. The
    ``values`` is a vector of symbols, these symbols being the keys of the
    ``MolecularDynamic.data`` dictionairy. The ``header`` string will be writen
    on the top of the output file.

    Usage example:

    .. code-block:: julia

        sim = MolecularDynamic(1.0)

        # TemperatureCompute register a :temperature key
        add_compute(sim, TemperatureCompute())

        temperature_output = CustomOutput("Sim-Temp.dat", [:temperature])
        add_output(sim, temperature_output)


Reusable output: subtyping ``BaseOutput``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An other way to create a custom output is to subtype ``BaseOutput``. The subtyped
type must have two integer fields: ``current`` and ``frequency``, and the constructor
should initialize ``current`` to 0. The ``write`` function should also be overloaded
for the signature ``write(::BaseOutput, ::Dict)``. The dictionairy parameter
contains all the values set up by the :ref:`computation algorithms <simulation-computes>`,
and a special key ``:frame`` refering to the current simulation :ref:`frame <type-Frame>`.

``BaseOutput`` subtypes can also define a ``setup(::BaseOutput, ::MolecularDynamic)``
function to do some setup job, like adding the needed computations to the
simulation.

As an example, let's build a custom output writing the ``x`` position of the
first atom of the simulation at each step. This position will be taken from the
frame, so no specific computation algorithm is needed here. But this position
will be writen in bohr, so some conversion from Angstroms will be needed.

.. code-block:: julia

    # File FirstX.jl

    using Jumos

    import Base.write
    import Jumos.setup

    type FirstX <: BaseOutput
        file::IOStream
        current::Integer
        frequency::Integer
    end

    # Default values constructor
    function FirstX(filename, frequency=1)
        file = open(filename, "w")
        return FirstX(file, 0, frequency)
    end

    function write(out::FirstX, context::Dict)
        frame = context[:frame]
        x = frame.positions[1][1]
        x = x/0.529 # Converting to bohr
        write(out.file, "$x \n")
    end

    # Not needed here
    # function setup(::FirstX, ::MolecularDynamic)

This type can be used like this:

.. code-block:: julia

    using Jumos
    require("FirstX.jl")

    sim = MolecularDynamic(1.0)
    # ...

    add_output(sim, FirstX("The-first-x-file.dat"))
