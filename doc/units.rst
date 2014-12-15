.. _intenal_units:

Internal units
==============

*Jumos* uses a set of internal units, converting back and forth to these units
when needed. Conversion from SI units is always supported. Parenthesis indicate
planned conversion not yet implemented.

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
-------------------------------------

All the interaction with units is based on the `SIUnits <https://github.com/Keno/SIUnits.jl>`_
package. You can convert from and to internal representation using the following functions :

.. function:: internal(value::SIQuantity)

    Convert a value with unit to it's internal representation.

.. code-block:: jlcon

    julia> internal(2m)         # Distance
        1.9999999999999996e10

    julia> internal(3kg*m/s^2)  # Force
        7.17017208413002e-14

.. function:: with_unit(value::Number, target_unit::SIUnit)

    Convert an internal value to its value in the International System. The units are
    not tracked in the code, so you can convert a position to a pressure. All the results
    are returned in the main SI unit, without considering any power-of-ten prefix.
    This leads to weird results like:

.. code-block:: jlcon

    julia> with_unit(45, mJ)
        188280.0 kg m²/s²

    julia> with_unit(45, J)
        188280.0 kg m²/s²
