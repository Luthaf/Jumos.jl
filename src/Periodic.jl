#===============================================================================
       Atomic informations: mass, Van der Waals radii, names aliases, etc.
===============================================================================#

const ATOMIC_MASSES = Dict( # Values in g/mol
    "Ac"=> 227.028,
    "Ag"=> 107.8682,
    "Al"=> 26.981539,
    "Am"=> 243.0,
    "Ar"=> 39.948,
    "As"=> 74.92159,
    "At"=> 210.0,
    "Au"=> 196.96654,

    "B"=> 10.811,
    "Ba"=> 137.327,
    "Be"=> 9.012182,
    "Bh"=> 262.0,
    "Bi"=> 208.98037,
    "Bk"=> 247.0,
    "Br"=> 79.904,

    "C"=> 12.011,
    "Ca"=> 40.08,
    "Cd"=> 112.411,
    "Ce"=> 140.116,
    "Cf"=> 251.0,
    "Cl"=> 35.45,
    "Cm"=> 247.0,
    "Co"=> 58.9332,
    "Cu"=> 63.546,
    "Cr"=> 51.9961,
    "Cs"=> 132.9,

    "Db"=> 262.0,
    "Dy"=> 162.5,

    "Er"=> 167.26,
    "Es"=> 252.0,
    "Eu"=> 151.965,

    "F"=> 18.998,
    "Fe"=> 55.847,
    "Fm"=> 257.0,
    "Fr"=> 223.0,

    "Ga"=> 69.723,
    "Gd"=> 157.25,
    "Ge"=> 72.61,

    "H"=> 1.008,
    "He"=> 4.0026,
    "Hf"=> 178.49,
    "Hg"=> 200.59,
    "Ho"=> 164.93032,
    "Hs"=> 265.0,

    "I"=> 126.9045,
    "Ir"=> 192.22,
    "In"=> 114.82,

    "K"=> 39.102,
    "Kr"=> 83.8,

    "La"=> 138.9055,
    "Li"=> 6.941,
    "Lr"=> 262.0,
    "Lu"=> 174.967,

    "Md"=> 258.0,
    "Mg"=> 24.305,
    "Mn"=> 54.93805,
    "Mo"=> 95.94,
    "Mt"=> 266.0,

    "N"=> 14.007,
    "Na"=> 22.989768,
    "Nb"=> 92.90638,
    "Nd"=> 144.24,
    "Ne"=> 20.1797,
    "Ni"=> 58.6934,
    "No"=> 259.0,
    "Np"=> 237.048,

    "O"=> 15.999,
    "Os"=> 190.2,

    "P"=> 30.974,
    "Pa"=> 231.0359,
    "Pb"=> 207.2,
    "Pd"=> 106.42,
    "Pm"=> 145.0,
    "Po"=> 209.0,
    "Pr"=> 140.90765,
    "Pt"=> 195.08,
    "Pu"=> 244.0,

    "Ra"=> 226.025,
    "Rb"=> 85.4678,
    "Re"=> 186.207,
    "Rf"=> 261.0,
    "Rh"=> 102.9055,
    "Rn"=> 222.0,
    "Ru"=> 101.07,

    "S"=> 32.06,
    "Sb"=> 121.757,
    "Sc"=> 44.95591,
    "Se"=> 78.96,
    "Sg"=> 263.0,
    "Si"=> 28.0855,
    "Sm"=> 150.36,
    "Sn"=> 118.71,
    "Sr"=> 87.62,

    "Ta"=> 180.9479,
    "Tb"=> 158.92534,
    "Tc"=> 98.0,
    "Te"=> 127.6,
    "Th"=> 232.0381,
    "Ti"=> 47.88,
    "Tl"=> 204.3833,
    "Tm"=> 168.93421,

    "U"=> 238.0289,

    "V"=> 50.9415,

    "W"=> 183.85,

    "Xe"=> 131.29,

    "Y"=> 88.90585,
    "Yb"=> 173.04,

    "Zn"=> 65.37,
    "Zr"=> 91.224
)

const VDW_RADIUS = Dict( # Values in pm
    "H" => 120,
    "Zn" => 139,
    "He" => 140,
    "Cu" => 140,
    "F" => 147,
    "O" => 152,
    "Ne" => 154,
    "N" => 155,
    "Hg" => 155,
    "Cd" => 158,
    "Ni" => 163,
    "Pd" => 163,
    "Au" => 166,
    "C" => 170,
    "Ag" => 172,
    "Mg" => 173,
    "Cl" => 175,
    "Pt" => 175,
    "P" => 180,
    "S" => 180,
    "Li" => 182,
    "Ar" => 185,
    "Br" => 185,
    "U" => 186,
    "Ga" => 187,
    "Ar" => 188,
    "Se" => 190,
    "In" => 193,
    "Th" => 196,
    "I" => 198,
    "Kr" => 202,
    "Pb" => 202,
    "Te" => 206,
    "Si" => 210,
    "Xe" => 216,
    "Sn" => 217,
    "Na" => 227,
    "K" => 275,
)
