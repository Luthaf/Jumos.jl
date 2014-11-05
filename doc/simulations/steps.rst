Usual simulation steps
======================

.. note::
    This section describe generalities, and all the capacities presented here may
    not be implemented in `Jumos`. However, it describe exactly the steps invloved
    in preparing and running a simulation with `Jumos`, so it is worth reading it.

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

The topology of a simulation is a representation of the atoms, molecules, groups
of molecules one can find in this simulation. It can be read from a file
(:file:`.pdb` files ,:file:`.lmp` LAMMPS topology, …) ; gessed from the initial
configuration (two atoms are linked if they are closer than the sum of there Van
der Waals radii) ; or buildt by hand.

Setup interaction
^^^^^^^^^^^^^^^^^

The interactions describe how atoms should interact : they can be pair potentials,
many-body potentials, bond potentials, torsion potentials, dihedral potentials or
any other kind of interaction energy.

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
randomly assigned. In the later case, it is a better idea to use a Maxwell-Boltzman
distribution at the temperature :math:`T` of the simulation.

Setup simulation
^^^^^^^^^^^^^^^^

Some other values will have to be set in order to run a simulation, depending on
the kind of simulation: the timestep of integration :math:`dt`, the type of
thermostat or barostat to use, `etc.`

Running the simulation
----------------------

The order of the steps in a simulation run can not be changed.

Get forces
^^^^^^^^^^

The first step, and the more time consuming one, is to get the forces octing on
each one of the atoms. Various way to do this computation exist, depening on the
type of potentials (short range or long range), and some ticks can speed up the
computation (pairs list, short range potential truncation).

Integrate
^^^^^^^^^

Using the forces, one can now integrate the Newton's equations of motions.
The greatest variety of algorithm exists here: from simple volecity-Verlet to
complex multi-timestep RESPA algorithm. At the end, postions and velocities are
updated to the new step.

Enforce
^^^^^^^

If the time integration does not force the value of external parameters, like
temperature or pressure or volume, this step can enforce them. Here will act the
berendsen thermostat, the velocity rescaling, the particle wrapping to the box.

Check
^^^^^

During the run, one can check for simulation consistency. For example, the number
of particle in the box may have be constant, the global momentum have to be zero,
and so on.

Compute
^^^^^^^

Running simulations is great, but worth nothing if no analysis is performed on
the trajectory. This step allow for computing and averaging physical quantities,
like total energy, kinetic energy, temperature, pressure, magnetic moment, and
plenty of other intersting quantities.

Output
^^^^^^

But computing these quantities is not enough. You have to write the to a file in
order to do save them. So here `Jumos` will output the computed values, and the
trajectories.
