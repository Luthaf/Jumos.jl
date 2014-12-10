module Constants
	using SIUnits.ShortUnits
	using Jumos.Units

    export kB, NA

    const kB = internal(1.3806488e-23J)
    const NA = 6.02214129e23
end
