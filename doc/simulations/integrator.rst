.. _type-Integrator:

Integrator: running the simulation
==================================

An integrator is an algorithm responsible for updating the positions and the
velocities of the current :ref:`frame <type-Frame>` of the :ref:`simulation
<type-Simulation>`.

Verlet integrators
------------------

Verlet integrators are based on Taylor expensions of Newton's second law.
They provide a simple way to integrate the movement, and conserve the energy
if a sufficently small timestep is used. Assuming the absence of barostat and
thermostat, they provide a NVE integration.

Verlet
^^^^^^

The Verlet algorithm is described `here <http://www.fisica.uniud.it/~ercolessi/md/md/node21.html>`_.
The main constructor for this integrator is ``Verlet(timestep)``, where ``timestep``
is the timestep in femtosecond.

.. _type-VelocityVerlet:

Velocity-Verlet
^^^^^^^^^^^^^^^

The velocity-Verlet algorithm is descibed extensively in the literature, for
example in this `webpages <http://www.fisica.uniud.it/~ercolessi/md/md/node21.html>`_.
The main constructor for this integrator is ``VelocityVerlet(timestep)``, where
``timestep`` is the integration timestep in femtosecond. This is the default
integration algorithm in `Jumos`.

Writing a new integrator
------------------------

To create a new integrator, you have to subtype the ``BaseIntegrator`` type, and
provide the ``call`` method, with the following signature:
``call(::BaseIntegrator, ::MolecularDynamic)``.

The integrator is responsible for calling the ``get_forces!(::MolecularDynamic)``
function if it need the ``MolecularDynamic.forces`` field to be updated. It should
update the two :ref:`Array3D <type-Array3D>`: ``MolecularDynamic.frame.positions``
and ``MolecularDynamic.frame.velocities`` with appropriate values.

The ``MolecularDynamic.masses`` field is a ``Vector{Float64}`` containing the particles
masses, in the same order than in the current simulation :ref:`frame <type-Frame>`.
Any other required information should be stored in the new ``BaseIntegrator`` subtype.
