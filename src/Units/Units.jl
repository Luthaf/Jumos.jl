#===============================================================================
                            Chemistry specific units
===============================================================================#

import SIUnits: NonSIUnit, SIQuantity
#==============================================================================#
# Non SI units
export Calorie, Angstrom, Ångström, AtomicMass, Bar, Atmosphere

const Calorie = NonSIUnit{typeof(Joule),:cal}()
convert(::Type{SIQuantity},::typeof(Calorie)) = 4.184Joule

const Angstrom = NonSIUnit{typeof(Meter),:Å}()
convert(::Type{SIQuantity},::typeof(Angstrom)) = 0.1Nano*Meter

const AtomicMass = NonSIUnit{typeof(KiloGram),:amu}()
convert(::Type{SIQuantity},::typeof(AtomicMass)) = 1.660538921*10^(-27)KiloGram

const Bar = NonSIUnit{typeof(Pascal),:bar}()
convert(::Type{SIQuantity},::typeof(Bar)) = 10^(5)Pascal

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
