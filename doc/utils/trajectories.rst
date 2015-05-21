.. _trajectories:

Trajectories
============

When running molecular simulations, the trajectory of the system is commonly saved
to the disk in prevision of future analysis or new simulations run. The `Trajectories`
module offers facilities to read and write this files.

Reading and writing trajectories
--------------------------------

One can read or write :ref:`frames <type-Frame>` from a trajectory. In order
to do so,  more information is needed : namely an :ref:`unit cell <type-UnitCell>`
and a :ref:`topology <type-Topology>`. Both are optional, but allow for better
computations. Some file formats already contain this kind of informations so there
is no need to provide it.

Trajectories can exist in differents formats: text formats like the `XYZ`_ format,
or binary formats. In |Jumos|, the format of a trajectory file is automatically
determined based on the file extension.

Base types
^^^^^^^^^^

The two basic types for reading and writing trajectories in files are respectively
the ``Reader`` and the ``Writer`` parametrised types. For each specific format,
there is a ``FormatWriter`` and/or ``FormatReader`` subtype implementing
the basic operations.

Usage
^^^^^

The following functions are defined for the interactions with trajectory files.

.. function:: opentraj(filename, [mode="r", topology="", kwargs...])

    Opens a trajectory file for reading or writing. The ``filename`` extension
    determines the :ref:`format <trajectory-formats>` of the trajectory.

    The ``mode`` argument can be ``"r"`` for reading or ``"w"`` for writing.

    The ``topology`` argument can be the path to a :ref:`Topology <type-Topology>`
    file, if you want to use atomic names with trajectories files in which there
    is no topological informations.

    All the keyword arguments ``kwargs`` are passed to the specific constructors.

.. function:: Reader(filename [, kwargs...])

    Creates a ``Reader`` object, by passing the keywords arguments ``kwargs`` to
    the specific constructor. This is equivalent to use the `opentraj` function
    with ``"r"`` mode.

.. function:: Writer(filename [, kwargs...])

    Creates a ``Writer`` object, by passing the keywords arguments ``kwargs`` to
    the specific constructor. This is equivalent to use the `opentraj` function
    with ``"w"`` mode.

.. function:: eachframe(::Reader [range::Range, start=first_step])

    This function creates an [interator] interface to a ``Reader``, allowing for
    constructions like ``for frame in eachframe(reader)``.

.. function:: read_next_frame!(::Reader, frame)

    Reads the next frame from  ``Reader``, and stores it into ``frame``.
    Raises an error in case of failure, and returns ``true`` if there are
    other frames to read, ``false`` otherwise.

    This function can be used in constructions such as ``while read_next_frame!(traj)``.

.. function:: read_frame!(::Reader, step, frame)

    Reads a frame at the step ``step`` from the ``Reader``, and stores it into
    ``frame``. Raises an error in the case of failure and returns ``true`` if there
    is a frame after the step ``step``, ``false`` otherwise.

.. function:: write(::Writer, frame)

    Writes the :ref:`Frame <type-Frame>` ``frame`` to the file associated with the
    ``Writer``.

.. function:: close(trajectory_file)

    Closes the file associated with a ``Reader`` or a ``Writer``.

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

Here is an example of how you can write frames to a file. This example converts a
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

The following table summarizes the formats supported by |Jumos|, giving the reading
and writing capacities of |Jumos|, as well as the presence or absence of the unit cell
and the topology information in the files. The last column indicates the accepted keywords.

+------------------+--------------+--------+---------+---------+------------+-------------+
|    Format        | Extension    | Read   | Write   |  Cell   | Topology   |  Keywords   |
+==================+==============+========+=========+=========+============+=============+
| `XYZ`_           | :file:`.xyz` | |yes|  | |yes|   |  |no|   | |yes|      |  cell       |
+------------------+--------------+--------+---------+---------+------------+-------------+
| `Amber NetCDF`_  | :file:`.nc`  | |yes|  | |no|    |  |yes|  | |no|       |  topology   |
+------------------+--------------+--------+---------+---------+------------+-------------+

.. _XYZ: http://openbabel.org/wiki/XYZ
.. _Amber NetCDF: http://ambermd.org/netcdf/nctraj.xhtml

.. |yes| image:: /_static_/img/yes.png
          :alt: Yes
          :width: 16px
          :height: 16px

.. |no| image:: /_static_/img/no.png
          :alt: No
          :width: 16px
          :height: 16px

Readind and writing topologies
-------------------------------

`Topologies <type-Topology>`_ can also be represented and stored in files. Some
functions allow to read directly these files, but there is usally no need to use
them directely.

Supported formats for topology
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Topology reading supports the formats in the following table.

+----------------------+------------+------------+
|    Format            | Reading ?  | Writing ?  |
+======================+============+============+
| `XYZ`_               |  |yes|     | |yes|      |
+----------------------+------------+------------+
| `LAMMPS`_ data file  |  |yes|     | |no|       |
+----------------------+------------+------------+

.. _LAMMPS: http://lammps.sandia.gov/doc/read_data.html

If you want to write a toplogy to a file, the best way for now is to create a
frame with this topology, and write this frame to an XYZ file.

.. Adding new formats
   ^^^^^^^^^^^^^^^^^^^
   Needed functions: get_traj_infos(::Reader), read_frame!(traj::Reader{XYZReader}, step::Integer, frame::Frame)
   read_next_frame!(traj::Reader{XYZReader}, frame::Frame), close
   .. function:: register_writer(extension="ext", filetype="File Type", writer=WriterType)
   .. function:: register_reader(extension="ext", filetype="File Type", reader=ReaderType)
