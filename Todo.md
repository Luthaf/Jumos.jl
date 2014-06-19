# Trajectories formats

Add the following : 

 - Gromacs binary and text
 - LAMMPS native binary and text
 - PDB and PSF

See what is used by :

 - CHARMM,
 - NAMD,
 - Amber.


# Topology readers

Existing formats :

CHARMM/XPLOR 	psf 

CHARMM      	crd

XPDB 	        pdb

PQR            	pqr

PDBQT        	pdbqt

GROMOS96     	gro

AMBER 	        top, prmtop

DESRES       	dms

TPR 	        tpr

# Selections

Add selections (as functions) for picking and slicing arrays
 - VMD style

Use a string macro: s"atom a and z<4", defined with macro s_str ... end

# Functionalities

From the Python MDAnalysis

#### Distances and contacts

 - Coordinate fitting and alignment
 - Native contacts analysis
 - Distance analysis
 - Hydrogen Bond analysis
 - Calculating root mean square quantities

#### Membranes and membrane proteins

 - Generation and Analysis of HOLE pore profiles
 - Leaflet identification

#### Nucleic acids

 - Nucleic acid analysis
 - Generation and Analysis of X3DNA helicoidal parameter profiles

#### Structure

 - Elastic network analysis of MD trajectories
 - HELANAL — analysis of protein helices

#### Volumetric analysis

 - Generating densities from trajectories — MDAnalysis.analysis.density


# Algorithm improvement

Use parrallelisation somewhere

See : 

 - http://mdanalysis.googlecode.com/git/package/doc/html/documentation_pages/core/distances.html
 - http://mdanalysis.googlecode.com/git/package/doc/html/documentation_pages/core/transformations.html
 - http://mdanalysis.googlecode.com/git/package/doc/html/documentation_pages/core/parallel.html




