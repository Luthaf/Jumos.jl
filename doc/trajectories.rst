.. _trajectories:

Trajectories
============

When running molecular simulations, the trajectory of the system is commonly saved
to the disk in prevision of future analysis or new simulations run. The `Trajectories`
module offer facilities to read and write this kind of files.

Reading and writing trajectories
--------------------------------

From a trajectory, one want to read or write :ref:`frames <type-Frame>`. In order
to do so, some other informations are needed : namely an :ref:`unit cell <type-UnitCell>`
and a :ref:`topology <type-Topology>`. Both are optionals, but allow for better
computations. Some file format already contains this kind of informations, so there
is no need to provide it.

Trajectories can exist in differents formats: text formats like the `XYZ`_ format,
or binary formats. In `Jumos`, the format of a trajectory file is automatically
guessed based on the file extension.

Base types
^^^^^^^^^^

The two base types for reading and writing trajectories in files are respectively
the ``Reader`` and the ``Writer`` parametrised types. For each specific format,
there will be a ``FormatWriter`` and/or ``FormatReader`` subtype implementing
the basic operations.

Usage
^^^^^

The following functions are defined for the interactions with trajectory files.

.. function:: opentraj(filename, [mode="r", topology="", kwargs...])

    Open a trajectory file for reading or writing. The ``filename`` extension
    determine the :ref:`format <trajectory-formats>` of the trajectory.

    The ``mode`` argument can be ``"r"`` for reading or ``"w"`` for writing.

    The ``topology`` argument can be the path to a :ref:`Topology <type-Topology>`
    file, if you want to use atomic names with trajectories files in which there
    is no topological informations.

    All the keyword arguments ``kwargs`` are passed to the specific constructors.

.. function:: Reader(filename [, kwargs...])

    Create a ``Reader`` object, by passing the keywords arguments ``kwargs`` to
    the specific constructor. This is equivalent to use the `opentraj` function
    with ``"r"`` mode.

.. function:: Writer(filename [, kwargs...])

    Create a ``Writer`` object, by passing the keywords arguments ``kwargs`` to
    the specific constructor. This is equivalent to use the `opentraj` function
    with ``"w"`` mode.

.. function:: eachframe(::Reader [range::Range, start=first_step])

    This function create an interator interface to a ``Reader``, allowing for
    constructions like ``for frame in eachframe(reader)``.

.. function:: read_next_frame!(::Reader, frame)

    Read the next frame from  ``Reader``, and store it into ``frame``.
    Raise an error in case of failure, and return ``true`` if their is some
    other frame to read, ``false`` otherwise.

    This function can be use in constructions like ``while read_next_frame!(traj)``.

.. function:: read_frame!(::Reader, step, frame)

    Read a frame at the step ``step`` from the ``Reader``, and store it into
    ``frame``. Raise an error in the case of failure and return ``true`` if their
    is a frame after the step ``step``, ``false`` otherwise.

.. function:: write(::Writer, frame)

    Write the :ref:`Frame <type-Frame>` ``frame`` to the file associated with the
    ``Writer``.

.. function:: close(trajectory_file)

    Close the file associated with a ``Reader`` or a ``Writer``.

Reading frames from a file
""""""""""""""""""""""""""

Here is an example of how you can read frames from a file. In the ``Reader``
constructor, the ``cell`` keyword argument will be used to construct an
:ref:`UnitCell <type-UnitCell>`.

.. code-block:: julia

    traj_reader = Reader("filename.xyz", cell=[10., 10., 10.])

    for frame in eachframe(traj_reader)
        # Do stuff here
    end

    close(traj_reader)

Writing frames in a file
""""""""""""""""""""""""

Here is an example of how you can write frames to a file. This example convert a
trajectory from a file format to another. The ``topology`` keyword is used to
read a :ref:`Topology <type-Topology>` from a file.

.. code-block:: julia

    traj_reader = Reader("filename-in.nc", topology="topology.xyz")
    traj_writer = Writer("filename-out.xyz")

    for frame in eachframe(traj_reader)
        write(traj_writer, frame)
    end

    close(traj_writer)
    close(traj_reader)

.. _trajectory-formats:

Supported formats
^^^^^^^^^^^^^^^^^

The following table summarise the formats supported by `Jumos`, giving the reading
and writing capacities of `Jumos`, as well as the presence or not of the unit cell
and the topology informations in the files. The last column give the accepted keywords.

+------------------+--------------+--------+---------+---------+------------+-------------+
|    Format        | Extension    | Read   | Write   |  Cell   | Topology   |  Keywords   |
+==================+==============+========+=========+=========+============+=============+
| `XYZ`_           | :file:`.xyz` | |yes|  | |yes|   |  |no|   | |yes|      |  cell       |
+------------------+--------------+--------+---------+---------+------------+-------------+
| `Amber NetCDF`_  | :file:`.nc`  | |yes|  | |no|    |  |yes|  | |no|       |  topology   |
+------------------+--------------+--------+---------+---------+------------+-------------+

.. _XYZ: http://openbabel.org/wiki/XYZ
.. _Amber NetCDF: http://ambermd.org/netcdf/nctraj.xhtml

.. |yes| image:: static/img/yes.png
          :alt: Yes

.. |no| image:: static/img/no.png
          :alt: No

Readind and writing topologies
-------------------------------

`Topologies <type-Topology>`_ can also be represented and stored in files. Some
functions allow to read directly these file, but you don't usally need to use them
directely.

Supported formats for topology
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The folowing formats are suported for topology reading. If you want to write a
toplogy to a file, the best way for now is to create a frame with this topology,
and write this frame to an XYZ file.

+----------------------+------------+------------+
|    Format            | Reading ?  | Writing ?  |
+======================+============+============+
| `XYZ`_               |  |yes|     | |yes|      |
+----------------------+------------+------------+
| `LAMMPS`_ data file  |  |yes|     | |no|       |
+----------------------+------------+------------+

.. _LAMMPS: http://lammps.sandia.gov/doc/read_data.html

.. Adding new formats
   ^^^^^^^^^^^^^^^^^^^
   Needed functions: get_traj_infos(::Reader), read_frame!(traj::Reader{XYZReader}, step::Integer, frame::Frame)
   read_next_frame!(traj::Reader{XYZReader}, frame::Frame), close
   .. function:: register_writer(extension="ext", filetype="File Type", writer=WriterType)
   .. function:: register_reader(extension="ext", filetype="File Type", reader=ReaderType)
