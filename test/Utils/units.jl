facts("Units conversions") do
    # Internal unit
    @fact unit_from(10.0, "A") => 10.0
    # Unicode unit
    @fact unit_from(10.0, "Å") => 10.0
    # Not internal unit
    @fact unit_from(10.0, "bohr") => 10.0*0.52917720859

    # Composed unit
    @fact unit_from(10.0, "bohr/fs") => 10.0*0.52917720859
    @fact unit_from(10.0, "kJ/mol/A^2") => roughly(1e-3)
    @fact unit_from(10.0, "Ry/rad^-3") => 1.3127498789124936
    @fact unit_from(10.0, "bar/m") => 6.0221417942167636e-18

    # Parsing errors
    @fact_throws unit_from(10.0, "(bar/m")
    @fact_throws unit_to(10.0, "(bar/m")
    @fact_throws unit_from(10.0, "m^4.8")
    @fact_throws unit_from(10.0, "m/K)")
    @fact_throws unit_from(10.0, "HJK")

    @fact unit_to(25.0, "m") => 2.5e-9
    @fact unit_to(25.0, "bar") => 4.1513469550000005e9
    @fact unit_to(25.0, "kJ/mol") => roughly(250000)
end
