.. _type-Frame:

Frame
=====

A ``Frame`` object holds the data from one step of a simulation. It is defined as

.. code-block:: julia

    type Frame
        step::Integer
        cell::UnitCell
        topology::Topology
        positions::Array3D
        velocities::Array3D
    end

`i.e.` it contains information about the current step, the current
:ref:`cell <type-UnitCell>` shape, the current :ref:`topology <type-Topology>`,
the current positions, and possibly the current velocities. If there is no
velocity information, the velocities ``Array3D`` is a 0-sized array.

Creating frames
---------------

There are two ways to create frames: either explicitly or implicity. Explicit
creation uses one of the constructors below. Implicit creation occurs while
reading frames from a stored trajectory or from running a simulation.

The Frame type have the following constructors:

.. function:: Frame(::Topology)

    Creates a frame given a topology. The arrays are pre-allocated to store data
    according to the topology.

.. function:: Frame()

    Creates an empty frame, with a 0-atoms topology.

Reading and writing frames from files
-------------------------------------

The main goal of the ``Trajectories`` module is to read or write frames from or to
files. See this module :ref:`documentation <trajectories>` for more information.
