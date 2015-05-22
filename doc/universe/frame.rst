.. _type-Frame:

Frame
=====

A ``Frame`` object holds the data which is specific to one step of a simulation.
It is defined as:

.. code-block:: julia

    type Frame
        positions::Array3D
        velocities::Array3D
        step::Integer
    end

`i.e.` it contains information about the current step, the current positions,
and possibly the current velocities. If there is no velocity information, the
velocities :ref:`Array3D <type-array3d>` is a 0-sized array.

The ``Frame`` type have the following constructor:

.. function:: Frame([natom=0])

    Creates a frame with space for ``natoms`` particles.
