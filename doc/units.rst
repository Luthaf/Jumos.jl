Internal units
==============

*Jumos* uses a set of internal units, converting back and forth to these units
when needed. Conversion from SI units is always supported.

+---------------+-------------------------------------------------+-------------------------+
|    Quantity   | Internal unit                                   | Supported conversions   |
+===============+=================================================+=========================+
| Distances     | Ångtröm (:math:`Å`)                             |  (bohr)                 |
+---------------+-------------------------------------------------+-------------------------+
| Time          | Femptosecond (:math:`fs`)                       |                         |
+---------------+-------------------------------------------------+-------------------------+
| Velocities    | Ångtröm/Femptosecond (:math:`Å/fs`)             |                         |
+---------------+-------------------------------------------------+-------------------------+
| Mass          | Unified atomic mass (:math:`u` or :math:`Da`)   | :math:`g/mol`           |
+---------------+-------------------------------------------------+-------------------------+
| Temperature   | Kelvin (:math:`K`)                              |                         |
+---------------+-------------------------------------------------+-------------------------+
| Energy        | Kilo-calorie/Mole (:math:`kcal/mol`)            | :math:`eV`,             |
|               |                                                 | :math:`Ry`              |
+---------------+-------------------------------------------------+-------------------------+
| Force         | Kilo-calorie/(Mole-Ångtröm) :math:`kcal/(mol Å)`|                         |
+---------------+-------------------------------------------------+-------------------------+
| Pressure      | :math:`bar`                                     |  :math:`atm`            |
+---------------+-------------------------------------------------+-------------------------+
| Charge        | Multiples of :math:`e = 1.602176487\ 10^{-19}C` |                         |
+---------------+-------------------------------------------------+-------------------------+


Interaction with others units systems
-------------------------------------

All the interaction with units is based on the `SIUnits <https://github.com/Keno/SIUnits.jl>`_
package. You can convert from and to internal representation using the following functions :

.. function:: internal(value::SIValue)

Convert a value with unit to it's internal representation.

.. code-block:: jlcon

    julia> internal(2m)
        2.0e10
    julia> internal(3g/mol)
        3.0

.. function:: with_unit(value, unit::SIunit)

Convert an internal value to a value with unit. The unit is not tracked in the
code, so you can convert a position to a pressure value. ``value`` can be a
``Number`` or a n-dimensional array of ``Number``.

.. code-block:: jlcon

    julia> with_unit(45, Milli*Joule)
        TODO
