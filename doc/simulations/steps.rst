Usual simulation steps
======================

In every molecular dynamics simulation, the main steps are roughly the sames.
One shall start by setting the simulation : positions of the particles,
velocities (either from a file or from a random gaussian distribution), timestep,
atomic types, potential to use beetween the atoms, and so on.

Then one run the simulation for a given number of steps ``n_run``. During the
run, the three main steps are computing the forces from the potentials,
integrating the movement and outputing the quantities of interest : trajectories,
energy, temperature, pressure, `etc.`

These two parts are summarised in the figure below.

.. image:: /static/img/MD_steps.*

Setting the simulation
----------------------

Here, one is building his simulation. The order of the steps doesn't
matter that much: you should start by defining the simulation box, and you have
to define a topology before defining the initial positions, but you can setup
the interactions at any time.

Get topology
^^^^^^^^^^^^

TODO

Setup interaction
^^^^^^^^^^^^^^^^^

TODO

Get initial positions
^^^^^^^^^^^^^^^^^^^^^

TODO

Get initial velocities
^^^^^^^^^^^^^^^^^^^^^^

TODO

Setup simulation
^^^^^^^^^^^^^^^^

TODO

Running the simulation
----------------------

The order of the steps in a simulation run can not be changed.

Get forces
^^^^^^^^^^

TODO

Integrate
^^^^^^^^^

TODO

Enforce
^^^^^^^

TODO

Check
^^^^^

TODO

Compute
^^^^^^^

TODO

Output
^^^^^^

TODO
