# Copyright (c) Guillaume Fraux 2014
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
    :Ac => 227.028amu,
    :Ag => 107.8682amu,
    :Al => 26.981539amu,
    :Am => 243.0amu,
    :Ar => 39.948amu,
    :As => 74.92159amu,
    :At => 210.0amu,
    :Au => 196.96654amu,

    :B => 10.811amu,
    :Ba => 137.327amu,
    :Be => 9.012182amu,
    :Bh => 262.0amu,
    :Bi => 208.98037amu,
    :Bk => 247.0amu,
    :Br => 79.904amu,

    :C => 12.011amu,
    :Ca => 40.08amu,
    :Cd => 112.411amu,
    :Ce => 140.116amu,
    :Cf => 251.0amu,
    :Cl => 35.45amu,
    :Cm => 247.0amu,
    :Co => 58.9332amu,
    :Cu => 63.546amu,
    :Cr => 51.9961amu,
    :Cs => 132.9amu,

    :Db => 262.0amu,
    :Dy => 162.5amu,

    :Er => 167.26amu,
    :Es => 252.0amu,
    :Eu => 151.965amu,

    :F => 18.998amu,
    :Fe => 55.847amu,
    :Fm => 257.0amu,
    :Fr => 223.0amu,

    :Ga => 69.723amu,
    :Gd => 157.25amu,
    :Ge => 72.61amu,

    :H => 1.008amu,
    :He => 4.0026amu,
    :Hf => 178.49amu,
    :Hg => 200.59amu,
    :Ho => 164.93032amu,
    :Hs => 265.0amu,

    :I => 126.9045amu,
    :Ir => 192.22amu,
    :In => 114.82amu,

    :K => 39.102amu,
    :Kr => 83.8amu,

    :La => 138.9055amu,
    :Li => 6.941amu,
    :Lr => 262.0amu,
    :Lu => 174.967amu,

    :Md => 258.0amu,
    :Mg => 24.305amu,
    :Mn => 54.93805amu,
    :Mo => 95.94amu,
    :Mt => 266.0amu,

    :N => 14.007amu,
    :Na => 22.989768amu,
    :Nb => 92.90638amu,
    :Nd => 144.24amu,
    :Ne => 20.1797amu,
    :Ni => 58.6934amu,
    :No => 259.0amu,
    :Np => 237.048amu,

    :O => 15.999amu,
    :Os => 190.2amu,

    :P => 30.974amu,
    :Pa => 231.0359amu,
    :Pb => 207.2amu,
    :Pd => 106.42amu,
    :Pm => 145.0amu,
    :Po => 209.0amu,
    :Pr => 140.90765amu,
    :Pt => 195.08amu,
    :Pu => 244.0amu,

    :Ra => 226.025amu,
    :Rb => 85.4678amu,
    :Re => 186.207amu,
    :Rf => 261.0amu,
    :Rh => 102.9055amu,
    :Rn => 222.0amu,
    :Ru => 101.07amu,

    :S => 32.06amu,
    :Sb => 121.757amu,
    :Sc => 44.95591amu,
    :Se => 78.96amu,
    :Sg => 263.0amu,
    :Si => 28.0855amu,
    :Sm => 150.36amu,
    :Sn => 118.71amu,
    :Sr => 87.62amu,

    :Ta => 180.9479amu,
    :Tb => 158.92534amu,
    :Tc => 98.0amu,
    :Te => 127.6amu,
    :Th => 232.0381amu,
    :Ti => 47.88amu,
    :Tl => 204.3833amu,
    :Tm => 168.93421amu,

    :U => 238.0289amu,

    :V => 50.9415amu,

    :W => 183.85amu,

    :Xe => 131.29amu,

    :Y => 88.90585amu,
    :Yb => 173.04amu,

    :Zn => 65.37amu,
    :Zr => 91.224amu
)

const VDW_RADIUS = Dict(
    :H => 120pm,
    :Zn => 139pm,
    :He => 140pm,
    :Cu => 140pm,
    :F => 147pm,
    :O => 152pm,
    :Ne => 154pm,
    :N => 155pm,
    :Hg => 155pm,
    :Cd => 158pm,
    :Ni => 163pm,
    :Pd => 163pm,
    :Au => 166pm,
    :C => 170pm,
    :Ag => 172pm,
    :Mg => 173pm,
    :Cl => 175pm,
    :Pt => 175pm,
    :P => 180pm,
    :S => 180pm,
    :Li => 182pm,
    :Ar => 185pm,
    :Br => 185pm,
    :U => 186pm,
    :Ga => 187pm,
    :Se => 190pm,
    :In => 193pm,
    :Th => 196pm,
    :I => 198pm,
    :Kr => 202pm,
    :Pb => 202pm,
    :Te => 206pm,
    :Si => 210pm,
    :Xe => 216pm,
    :Sn => 217pm,
    :Na => 227pm,
    :K => 275pm,
)
