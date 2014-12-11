module Constants
	using SIUnits.ShortUnits
	using Jumos.Units

    export kB, NA

    # TODO: make this work
    # const kB = internal(1.3806488e-23J/K)
    const kB = internal(1.3806488e-23J)*1e-4
    const NA = 6.02214129e23
end
