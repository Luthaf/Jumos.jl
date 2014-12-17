.. _simulation-steps:

Usual simulation steps
======================

.. note::
    This section describe generalities, and all the capacities presented here may
    not be implemented in `Jumos`. However, it describe exactly the steps invloved
    in preparing and running a simulation with `Jumos`, so it is worth reading.

In every molecular dynamics simulation, the main steps are roughly the same.
One shall start by setting the simulation : positions of the particles,
velocities (either from a file or from a random gaussian distribution), timestep,
atomic types, potential to use between the atoms, and so on.

Then run the simulation for a given number of steps ``n_run``. During the
run, the three main steps are computing the forces from the potentials,
integrating the movement and outputing the quantities of interest : trajectories,
energy, temperature, pressure, `etc.`

These two parts are summarised in the figure :ref:`fig-MD_steps`.

.. _fig-MD_steps:
.. figure:: /static/img/MD_steps.*
    :alt: Usual steps in a molecular dynamic simulation
    :align: center

    Usual steps in a molecular dynamic simulation

    A molecular dynamics simulation is usually built around two main parts, these
    parts being separated in various steps. The first part is sets the configuration,
    defining all the needed information about the simulation. The second part
    is the dynamics calculation, effectivelly running the simulation.

Setting the simulation
----------------------

Here, one is building his simulation. The order of the steps doesn't
matter that much: you should start by defining the simulation cell, and you have
to define a topology before defining the initial positions, but you can setup
the interactions at any time.

Get topology
^^^^^^^^^^^^

The topology of a simulation is a representation of the atoms, molecules, groups
of molecules one can find in this simulation. It can be read from a file
(:file:`.pdb` files ,:file:`.lmp` LAMMPS topology, …) ; guessed from the initial
configuration (two atoms are linked if they are closer than the sum of there Van
der Waals radii) ; or built by hand.

Setup interaction
^^^^^^^^^^^^^^^^^

The interactions describe how atoms should behave: they can be pair potentials,
many-body potentials, bond potentials, torsion potentials, dihedral potentials or
any other kinds of interactions.

Each of these potentials is associated with a force. This force is used in
molecular dynamics to integrate Newton's equations of motions.

Get initial positions
^^^^^^^^^^^^^^^^^^^^^

The initial positions of all the atoms in the system can be read from a file, or
defined by hand.

Get initial velocities
^^^^^^^^^^^^^^^^^^^^^^

The initial velocities are also needed to start the time integration in molecular
dynamics. They can be defined either in a file (to restart previous dynamic), or
randomly assigned. In the later case, it is a better idea to use a Maxwell-Boltzmann
distribution at the temperature :math:`T` of the simulation.

Setup simulation
^^^^^^^^^^^^^^^^

Some other values will have to be set in order to run a simulation, depending on
the kind of simulation: the timestep of integration :math:`dt`, the type of
thermostat or barostat to use.

Running the simulation
----------------------

The order of the steps in a simulation run is always the same, and can not be changed.

Integrate
^^^^^^^^^

Using the forces, one can now integrate Newton's equations of motions.
The greatest variety of algorithm exists here: from simple velocity-Verlet to
complex multi-timestep RESPA algorithm. At the end, postions and velocities are
updated to the new step.

Get forces
^^^^^^^^^^

During the integration steps, forces acting on the atoms will be needed. This
forces computing step is the most time consuming aspect of the calculation. Various ways 
to do this computation exists, depening on the type of potentials (short range or 
long range), and some tricks can speed up the computation (pairs list, short range potential 
truncation).

The algorithm used for integration have the responsability to call this step when
and as many times as needed.

Enforce
^^^^^^^

If the time integration does not force the value of external parameters, like
temperature or pressure or volume, this step can enforce them. Here will act the
Berendsen thermostat, the velocity rescaling, the particle wrapping to the cell.

Check
^^^^^

During the run, one can check for simulation consistency. For example, the number
of particles in the cell may have be constant, the global momentum has to be zero,
and so on.

Compute
^^^^^^^

Running a simulations is great, but worth nothing if no analysis is performed on
the trajectories. This step allows for computing and averaging physical quantities,
like total energy, kinetic energy, temperature, pressure, magnetic moment, and
plenty of other intersting quantities.

Output
^^^^^^

But computing these quantities is not enough. You have to write to a file in
order to do save them. So here `Jumos` will output the computed values, and the
trajectories.
