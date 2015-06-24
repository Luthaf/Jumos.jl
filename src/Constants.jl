# Copyright (c) Guillaume Fraux 2014-2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# ============================================================================ #
#                      Physical Constants in internal units
# ============================================================================ #

module Constants
	using Jumos.Units
	export kB, NA

    const kB = unit_from(1.3806488e-23, "J/K")
	const NA = Units.NA
end
