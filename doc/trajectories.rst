.. _trajectories:

Trajectories
============

When running molecular simulations, the trajectory of the system is commonly saved
to the disk in prevision of future analysis or new simulations run. The `Trajectories`
module offer facilities to read and write this kind of files.

Readind and writing trajectories
--------------------------------

From a trajectory, one want to read or write :ref:`frames <type-Frame>`. In order
to do so, some other informations are needed : namely an :ref:`unit cell <type-UnitCell>`
and a :ref:`topology <type-Topology>`. Both are optionals, but allow for better
computations. Some file format already contains this kind of informations, so there
is no need to provide it.

Supported formats
^^^^^^^^^^^^^^^^^

The following table summarise the formats supported by `Jumos`, giving the reading
and writing capacities of `Jumos`, as well as the presence or not of the unit cell
and the topology informations. It also give link to a specification of the
format.

+------------------+------------+------------+------------+------------+
|    Format        | Reading    | Writing    |    Cell    | Topology   |
+==================+============+============+============+============+
| `XYZ`_           |  Yes       | Yes        |   No       |  Yes       |
+------------------+------------+------------+------------+------------+
| `Amber NetCDF`_  |  Yes       | No         |   Yes      |  No        |
+------------------+------------+------------+------------+------------+

.. _XYZ: http://openbabel.org/wiki/XYZ
.. _Amber NetCDF: http://ambermd.org/netcdf/nctraj.xhtml

Readind and writing topologies
-------------------------------

Supported formats for topology
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+----------------------+------------+------------+
|    Format            | Reading ?  | Writing ?  |
+======================+============+============+
| `XYZ`_               |  Yes       | Yes        |
+----------------------+------------+------------+
| `LAMMPS`_ data file  |  Yes       | No         |
+----------------------+------------+------------+

.. _LAMMPS: http://lammps.sandia.gov/doc/read_data.html

.. Adding new formats
   ^^^^^^^^^^^^^^^^^^^
   Needed functions: get_traj_infos(::Reader), read_frame!(traj::Reader{XYZReader}, step::Integer, frame::Frame)
   read_next_frame!(traj::Reader{XYZReader}, frame::Frame), close
   .. function:: register_writer(extension="ext", filetype="File Type", writer=WriterType)
   .. function:: register_reader(extension="ext", filetype="File Type", reader=ReaderType)
