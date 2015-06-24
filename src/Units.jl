# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                           Chemistry specific units
# ============================================================================ #

export unit_from, unit_to

const U_IN_KG = 1.660538782e-27
const BOHR_RADIUS = 0.52917720859
const NA = 6.02214179e23

# Associating unit and conversion factors
const UNITS = Dict{AbstractString, Float64}(
    # Distance units. The internal unit for distances is the Angstrom
    "Å" => 1, "A"=> 1,
    "nm" => 10, "pm" => 1.e-2, "fm" => 1.e-5, "m" => 1.e10,
    "bohr" => BOHR_RADIUS,
    # Time units. The internal unit is the femtosecond
    "fs" => 1, "ps" => 1.e3, "ns" => 1.e6,
    # Mass units. The internal unit is the unified atomic mass unit (u or Da)
    "u" => 1, "Da" => 1, "Da" => 1,
    "kDa" => 1.e3, "g" => 1.e-3 / U_IN_KG,
    "kg" => 1 / U_IN_KG,
    # Temperature units. The internal unit is the Kelvin
    "K" => 1,
    # Quantity of matter units. The internal unit is the mole.
    "mol" => NA,

    # Angle units. The internal unit is the radian
    "rad" => 1, "deg" => pi / 180,

    # Energy units. The internal unit is "u*A^2/fs^2"
    "J" => 1.e-10 / U_IN_KG, "kJ" => 1.e-7 / U_IN_KG,
    "kcal" => 4.184 * 1.e-7 / U_IN_KG,
    "eV" => 1.60217653e-19 * (1.e-10 / U_IN_KG),
    "H" => 4.35974417e-18 * (1.e-10 / U_IN_KG),
    "Ry" => (4.35974417e-18 / 2) * (1.e-10 / U_IN_KG),

    # Force unit. The internal unit is "u*A/fs^2""
    "N" => 1.e-20 / U_IN_KG,

    # Pressure units. The internal unit is "" TODO
    "Pa" => 1.e-40 / U_IN_KG, "kPa" => 1.e-37 / U_IN_KG,
    "MPa" => 1.e-34 / U_IN_KG, "bar" => 1.e-35 / U_IN_KG,
    "atm" => 101325 * 1.e-40 / U_IN_KG,
)

type UnitError <: Exception
    unit::AbstractString
    message::AbstractString
end

UnitError(unit::AbstractString) = UnitError(unit, "")

function Base.show(io::IO, e::UnitError)
    if e.message != ""
        message = ". $(e.message)."
    else
        message = "."
    end
    show(io, "Unit conversion error. The unit was $(e.unit)$message")
end

# Recursive unit string parsing function
function conversion(sub::AbstractString, unit::AbstractString)
    const strlen = length(sub)

    if strlen == 0
        return 1
    end

    # First, check parentheses equilibration and any of '/' or '.' or '*' in the string
    depth = 0  # parentheses counter
    i = 0
    for j=1:strlen
        if sub[j] == '.' || sub[j] == '*' || isspace(sub[j]) || sub[j] == '/'
            i = j
        end

        if sub[j] == '('
            depth += 1
        elseif sub[j] == ')'
            depth -= 1
        end

        # No opening wihtout closing parentheses
        depth < 0 ? throw(UnitError(unit, "Parentheses are not equilibrated")) : nothing
    end
    depth != 0 ? throw(UnitError(unit, "Parentheses are not equilibrated")) : nothing

    # If a product character was found, recurse
    if i > 0
        lhs = conversion(sub[1:i-1], unit)
        rhs = conversion(sub[i+1:end], unit)

        if sub[i] == '/'
            return lhs / rhs
        elseif sub[j] == '.' || sub[j] == '*' || isspace(sub[j])
            return lhs * rhs
        else
            throw(UnitError(unit, "Unrecognized binary operator: $(sub[i])"))
        end
    end

    # Do we have an exponentiation?
    j = strlen
    while isdigit(sub[j]) || sub[j] == '-'
        j -= 1
    end
    if sub[j] == '^'
        i = j + 1
        while isdigit(sub[i]) || sub[i] == '-'
            i += 1
            if i > strlen
                i -= 1
                break
            end
        end

        power = tryparse(Int, sub[j+1:i])
        isnull(power) ? throw(UnitError(unit)) : nothing
        return ^(conversion(sub[1:j-1], unit), get(power))
    end

    # Are we enclosed by parentheses?
    if sub[1] == '('
        sub[end] != ')' ? throw(UnitError(unit), "Unbalanced parentheses") : nothing
        return conversion(sub[2 : end - 1], unit)
    end

    # Now, we should have a know unit
    if haskey(UNITS, sub)
        return UNITS[sub]
    else
        throw(UnitError(unit))
    end
end

conversion(unit::AbstractString) = conversion(unit, unit)

@doc "
`unit_from(val, unit)`

Convert the numeric value `val` from the unit `unit` to the internal unit.
" ->
function unit_from(val::Number, unit::AbstractString)
    factor = conversion(strip(unit))
    return factor * val
end

@doc "
`unit_to(val, unit)`

Convert the numeric value `val` (in internal units) to the unit `unit`.
" ->
function unit_to(val::Number, unit::AbstractString)
    factor = conversion(strip(unit))
    return val / factor
end
