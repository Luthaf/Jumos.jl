#===============================================================================
                            Chemistry specific units
===============================================================================#
import Base: convert, show
import SIUnits: SIUnit, NonSIUnit, SIQuantity, NonSIQuantity, unit
#==============================================================================#
# Non SI units
export Calorie, Angstrom, Ångström, AtomicMass, Bar, Atmosphere

const Calorie = NonSIUnit{typeof(Joule),:cal}()
convert(::Type{SIQuantity},::typeof(Calorie)) = 4.184Joule

const Angstrom = NonSIUnit{typeof(Meter),:Å}()
convert(::Type{SIQuantity},::typeof(Angstrom)) = 0.1Nano*Meter

const AtomicMass = NonSIUnit{typeof(KiloGram),:amu}()
convert(::Type{SIQuantity},::typeof(AtomicMass)) = 1.660538921e-27KiloGram

const Bar = NonSIUnit{typeof(Pascal),:bar}()
convert(::Type{SIQuantity},::typeof(Bar)) = 1e5Pascal

const Atmosphere = NonSIUnit{typeof(Pascal),:atm}()
convert(::Type{SIQuantity},::typeof(Bar)) = 101325Pascal

# UTF-8 version
const Ångström = Angstrom

#==============================================================================#
# Small names
export kcal, AA, Å, pm, amu, bar, atm

const kcal = Kilo * Calorie
const AA = Angstrom
const Å = Angstrom
const pm = Pico * Meter
const amu = AtomicMass
const bar = Bar
const atm = Atmosphere

const NA = 6.02214129e23
const mol = 1/NA


#==============================================================================#
# Conversions from NonSIUnit
/(x::NonSIUnit,y::NonSIQuantity) = convert(SIQuantity, x)/convert(SIQuantity, y)
/(x::NonSIQuantity,y::NonSIUnit) = convert(SIQuantity, x)/convert(SIQuantity, y)
/(x::SIQuantity,y::NonSIQuantity) = x/convert(SIQuantity, y)

#==============================================================================#
# Utility functions

export internal, with_unit

type UnitError <: Exception
    message::String
end

function show(io::IO, e::UnitError)
    show(io, "Unit conversion error: $(e.message)")
end


const INTERNAL_UNITS = Dict(
    typeof(Meter) => Angstrom,
    typeof(Second) => Femto*Second,
    typeof(Meter/Second) => Angstrom/(Femto*Second),
    typeof(KiloGram) => AtomicMass,
    # Using non typed mol constant to allow for conversions
    typeof(Joule) => Kilo*Joule/NA,
    typeof(KiloGram*Meter/Second^2) => kcal/Angstrom,
    typeof(Kelvin) => Kelvin,
)

function internal(val::SIQuantity)
    target_unit = nothing
    res = 0.0
    try
        target_unit = INTERNAL_UNITS[typeof(unit(val))]
    catch
        throw(UnitError(
            "Can not convert $(unit(val)) to internal representation"
            ))
    end

    try
        res = as(val, target_unit).val
    catch e
        try
            res = val/target_unit
        catch
            throw(e)
        end
    end
    return res
end

SI = Union(SIQuantity, NonSIQuantity, SIUnit, NonSIUnit)

unit(u::SIUnit) = u

function with_unit(value::Number, target_unit::SI)
    internal_unit = nothing
    try
        internal_unit = INTERNAL_UNITS[typeof(unit(target_unit))]
    catch
        throw(UnitError(
            "Can not find an internal representation for $target_unit"
            ))
    end
    return value*internal_unit
end
