# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#      Atomic informations: mass, Van der Waals radii, names aliases, etc.
# ============================================================================ #

export ATOMIC_MASSES, VDW_RADIUS, PERIODIC_TABLE

const PERIODIC_TABLE = [
:H ,                                                                :He,
:Li,:Be,                                        :B ,:C ,:N ,:O ,:F ,:Ne,
:Na,:Mg,                                        :Al,:Si,:P ,:S ,:Cl,:Ar,
:K ,:Ca,:Sc,:Ti,:V ,:Cr,:Mn,:Fe,:Co,:Ni,:Cu,:Zn,:Ga,:Ge,:As,:Se,:Br,:Kr,
:Rb,:Sr,:Y ,:Zr,:Nb,:Mo,:Tc,:Ru,:Rh,:Pd,:Ar,:Cd,:In,:Sn,:Sb,:Te,:I ,:Xe,
:Cs,:Ba,:La,:Hf,:Ta,:W ,:Re,:Os,:Ir,:Pt,:Au,:Hg,:Ti,:Pb,:Bi,:Po,:At,:Rn,
:Fr,:Ra,:Ac,:Rf,:Db,:Sg,:Bh,:Hs,:Mt,:Ds,:Rg,:Cn,

:Ce,:Pr,:Nd,:Pm,:Sm,:Eu,:Gd,:Tb,:Dy,:Ho,:Er,:Tm,:Yb,:Lu,
:Th,:Pa,:U ,:Np,:Pu,:Am,:Cm,:Bk,:Cf,:Es,:Fm,:Md,:No,:Lr
]

const ATOMIC_MASSES = Dict(
    :Ac => 227.028,
    :Ag => 107.8682,
    :Al => 26.981539,
    :Am => 243.0,
    :Ar => 39.948,
    :As => 74.92159,
    :At => 210.0,
    :Au => 196.96654,

    :B => 10.811,
    :Ba => 137.327,
    :Be => 9.012182,
    :Bh => 262.0,
    :Bi => 208.98037,
    :Bk => 247.0,
    :Br => 79.904,

    :C => 12.011,
    :Ca => 40.08,
    :Cd => 112.411,
    :Ce => 140.116,
    :Cf => 251.0,
    :Cl => 35.45,
    :Cm => 247.0,
    :Co => 58.9332,
    :Cu => 63.546,
    :Cr => 51.9961,
    :Cs => 132.9,

    :Db => 262.0,
    :Dy => 162.5,

    :Er => 167.26,
    :Es => 252.0,
    :Eu => 151.965,

    :F => 18.998,
    :Fe => 55.847,
    :Fm => 257.0,
    :Fr => 223.0,

    :Ga => 69.723,
    :Gd => 157.25,
    :Ge => 72.61,

    :H => 1.008,
    :He => 4.0026,
    :Hf => 178.49,
    :Hg => 200.59,
    :Ho => 164.93032,
    :Hs => 265.0,

    :I => 126.9045,
    :Ir => 192.22,
    :In => 114.82,

    :K => 39.102,
    :Kr => 83.8,

    :La => 138.9055,
    :Li => 6.941,
    :Lr => 262.0,
    :Lu => 174.967,

    :Md => 258.0,
    :Mg => 24.305,
    :Mn => 54.93805,
    :Mo => 95.94,
    :Mt => 266.0,

    :N => 14.007,
    :Na => 22.989768,
    :Nb => 92.90638,
    :Nd => 144.24,
    :Ne => 20.1797,
    :Ni => 58.6934,
    :No => 259.0,
    :Np => 237.048,

    :O => 15.999,
    :Os => 190.2,

    :P => 30.974,
    :Pa => 231.0359,
    :Pb => 207.2,
    :Pd => 106.42,
    :Pm => 145.0,
    :Po => 209.0,
    :Pr => 140.90765,
    :Pt => 195.08,
    :Pu => 244.0,

    :Ra => 226.025,
    :Rb => 85.4678,
    :Re => 186.207,
    :Rf => 261.0,
    :Rh => 102.9055,
    :Rn => 222.0,
    :Ru => 101.07,

    :S => 32.06,
    :Sb => 121.757,
    :Sc => 44.95591,
    :Se => 78.96,
    :Sg => 263.0,
    :Si => 28.0855,
    :Sm => 150.36,
    :Sn => 118.71,
    :Sr => 87.62,

    :Ta => 180.9479,
    :Tb => 158.92534,
    :Tc => 98.0,
    :Te => 127.6,
    :Th => 232.0381,
    :Ti => 47.88,
    :Tl => 204.3833,
    :Tm => 168.93421,

    :U => 238.0289,

    :V => 50.9415,

    :W => 183.85,

    :Xe => 131.29,

    :Y => 88.90585,
    :Yb => 173.04,

    :Zn => 65.37,
    :Zr => 91.224
)

const VDW_RADIUS = Dict(
    :H => unit_from(120, "pm"),
    :Zn => unit_from(139, "pm"),
    :He => unit_from(140, "pm"),
    :Cu => unit_from(140, "pm"),
    :F => unit_from(147, "pm"),
    :O => unit_from(152, "pm"),
    :Ne => unit_from(154, "pm"),
    :N => unit_from(155, "pm"),
    :Hg => unit_from(155, "pm"),
    :Cd => unit_from(158, "pm"),
    :Ni => unit_from(163, "pm"),
    :Pd => unit_from(163, "pm"),
    :Au => unit_from(166, "pm"),
    :C => unit_from(170, "pm"),
    :Ag => unit_from(172, "pm"),
    :Mg => unit_from(173, "pm"),
    :Cl => unit_from(175, "pm"),
    :Pt => unit_from(175, "pm"),
    :P => unit_from(180, "pm"),
    :S => unit_from(180, "pm"),
    :Li => unit_from(182, "pm"),
    :Ar => unit_from(185, "pm"),
    :Br => unit_from(185, "pm"),
    :U => unit_from(186, "pm"),
    :Ga => unit_from(187, "pm"),
    :Se => unit_from(190, "pm"),
    :In => unit_from(193, "pm"),
    :Th => unit_from(196, "pm"),
    :I => unit_from(198, "pm"),
    :Kr => unit_from(202, "pm"),
    :Pb => unit_from(202, "pm"),
    :Te => unit_from(206, "pm"),
    :Si => unit_from(210, "pm"),
    :Xe => unit_from(216, "pm"),
    :Sn => unit_from(217, "pm"),
    :Na => unit_from(227, "pm"),
    :K => unit_from(275, "pm"),
)
