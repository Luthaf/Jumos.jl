# Copyright (c) Guillaume Fraux 2014
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                      Physical Constants in internal units
# ============================================================================ #

module Constants
	using SIUnits.ShortUnits
	using Jumos

    export kB, NA

    # TODO: make this work
    # const kB = internal(1.3806488e-23J/K)
    const kB = internal(1.3806488e-23J)*1e-4
    const NA = 6.02214129e23
end
