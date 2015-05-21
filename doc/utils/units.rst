.. _intenal_units:

Internal units
==============

|Jumos| uses a set of internal units, converting back and forth to these units
when needed. Conversion from SI units is always supported. Parenthesis indicate
planned conversion that is not implemented yet.

+---------------+-------------------------------------------------+-------------------------+
|    Quantity   | Internal unit                                   | Supported conversions   |
+===============+=================================================+=========================+
| Distances     | Ångtröm (:math:`A`)                             |  (bohr)                 |
+---------------+-------------------------------------------------+-------------------------+
| Time          | Femptosecond (:math:`fs`)                       |                         |
+---------------+-------------------------------------------------+-------------------------+
| Velocities    | Ångtröm/Femptosecond (:math:`A/fs`)             |                         |
+---------------+-------------------------------------------------+-------------------------+
| Mass          | Unified atomic mass (:math:`u` or :math:`Da`)   | :math:`g/mol`           |
+---------------+-------------------------------------------------+-------------------------+
| Temperature   | Kelvin (:math:`K`)                              |                         |
+---------------+-------------------------------------------------+-------------------------+
| Energy        | Kilo-Joule/Mole (:math:`kJ/mol`)                | (:math:`eV`),           |
|               |                                                 | (:math:`Ry`),           |
|               |                                                 | (:math:`kcal/mol`)      |
+---------------+-------------------------------------------------+-------------------------+
| Force         | Kilo-Joule/(Mole-Ångtröm) :math:`kJ/(mol A)`    |                         |
+---------------+-------------------------------------------------+-------------------------+
| Pressure      | :math:`bar`                                     |  (:math:`atm`)          |
+---------------+-------------------------------------------------+-------------------------+
| Charge        | Multiples of :math:`e = 1.602176487\ 10^{-19}C` |                         |
+---------------+-------------------------------------------------+-------------------------+


Interaction with others units systems
=====================================

|Jumos| uses it's own unit system, and do not track the units in the code. All
the interaction with units is based on the `SIUnits <https://github.com/Keno/SIUnits.jl>`_
package. We can convert from and to internal representation using the following functions :

.. function:: internal(value::SIQuantity)

    Converts a value with unit to its internal representation.

    .. code-block:: jlcon

        julia> internal(2m)         # Distance
            1.9999999999999996e10

        julia> internal(3kg*m/s^2)  # Force
            7.17017208413002e-14

.. function:: with_unit(value::Number, target_unit::SIUnit)

    Converts an internal value to its value in the International System. You
    shall note that units are not tracked in the code, so you can convert a
    position to a pressure. And all the results are returned in the main SI unit,
    without considering any power-of-ten prefix.

    This may leads to strange results like:

    .. code-block:: jlcon

        julia> with_unit(45, mJ)
            188280.0 kg m²/s²

        julia> with_unit(45, J)
            188280.0 kg m²/s²

    This behaviour will be corrected in future versions.
