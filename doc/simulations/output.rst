.. _type-Output:

Exporting values of interest
============================

While running a simulation, some basic analysis can be performed and writen to
a data file. Further analysis can be differed by writing the trajectory to a
file, and running existing tools on these trajectories.

In |Jumos|, outputs are subtypes of the ``Output`` type, and can be added to
a simulation by using the ``push!`` function.

.. function:: push!(simulation, output)
    :noindex:

    Adds an :ref:`output <type-Output>` algorithm to the simulation list. If the
    algorithm is already present, a warning is issued. Usage example:

    .. code-block:: julia

        sim = Simulation(:md, 1.0)

        # Direct addition
        push!(sim, TrajectoryOutput("mytraj.xyz"))

        # Binding the output to a variable
        out = TrajectoryOutput("mytraj-2.xyz", 5)
        push!(sim, out)


Each output is by default writen to the disk at every simulation step. To speed-up
the simulation run and remove useless information, a *write frequency* can be used
as the last parameter of each output constructor. If this frequency is set to ``n``,
the values will be writen only every *n* simulaton steps. This frequency can also
be changed dynamically:

.. code-block:: julia

    # Frequency is set to 1 by default
    traj_out = TrajectoryOutput("mytraj.xyz")

    add_output(sim, traj_out)
    propagate!(sim, universe, 300) # 300 steps will be writen

    # Set frequency to 50
    traj_out.frequency = OutputFrequency(50)
    propagate!(sim, universe, 500) # 10 steps will be writen

Existing outputs
----------------

.. _type-TrajectoryOutput:

Trajectory output
^^^^^^^^^^^^^^^^^

The first thing one might want to save in a simulation run is the trajectory of
the system. Such trajectory can be used for visualisation, storage and further
analysis. The ``TrajectoryOutput`` provide a way to write this trajectory to a
file.

.. function:: TrajectoryOutput(filename, [frequency = 1])

    This construct a ``TrajectoryOutput`` which can be used to write a trajectory
    to a file. The trajectory format is guessed from the ``filename`` extension.
    This format must have write capacities, see :ref:`the list <trajectory-formats>`
    of supported formats in |Jumos|.

.. _type-EnergyOutput:

Energy output
^^^^^^^^^^^^^

The energy output write to a file the values of energy and temperature for the
current step of the simulation. Values writen are the current step, the kinetic
energy, the potential energy, the total energy and the temperature.

.. function:: EnergyOutput(filename, [frequency = 1])

    This construct a ``EnergyOutput`` which can be used to the energy evolution
    to a file.

Defining a new output
---------------------

Adding a new output with custom values, can be done either by using a custom output
or by :ref:`subtyping <new-output>` the ``Output`` type to define a new output. The
the former wayis to be prefered when adding a *one-shot* output, and the latter when
adding an output which will be re-used.

.. _type-CustomOutput:

Custom output
^^^^^^^^^^^^^

The ``CustomOutput`` type provide a way to build specific output. The data to be
writen should be :ref:`computed <type-compute>` before the output by adding the
specific algorithms to the current simulation. These computation algorithm set a
value in the ``MolecularDynamic.data`` dictionairy, which can be accessed during the
output step. See the :ref:`computation algorithms <type-compute>` page for a list of
keys.

.. function:: CustomOutput(filename, values, [frequency = 1; header=""])

    This create a ``CustomOutput`` to be writen to the file ``filename``. The
    ``values`` is a vector of symbols, these symbols being the keys of the
    ``Universe.data`` dictionary. The ``header`` string will be writen on the top of
    the output file, and can contains some metadata.

    Usage example:

    .. code-block:: julia

        sim = Simulation(:md, 1.0)

        # TemperatureCompute register a :temperature key
        push!(sim, TemperatureCompute())

        temperature_output = CustomOutput("Sim-Temp.dat", [:temperature], header="# step  T/K")
        push!(sim, temperature_output)
