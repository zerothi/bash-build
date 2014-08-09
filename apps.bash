#source applications/git.bash
msg_install --message "Installing the applications..."

# Analysis tools
source applications/bader.bash

source applications/siesta-stable.bash
source applications/siesta-dev.bash # my old ts-development
source applications/siesta-mattias.bash
#source applications/siesta-scf.bash # my ts-development
source applications/siesta-trunk.bash # siesta trunk development
#source applications/siesta-trunk-scf.bash # siesta trunk-scf development

source applications/lammps.bash

# Graphics applications
source applications/gnuplot.bash
source applications/molden.bash
source applications/xmgrace.bash
source applications/xcrysden.bash
source applications/vmd.bash
source applications/gdis.bash
source applications/povray.bash

# Create a module with default all plotting tools
create_module \
    --module-path $(build_get --module-path)-npa \
    -n "Nick Papior Andersen's script for loading GUI: $(get_c)" \
    -v $(pack_get --version) \
    -M gnuplot.molden.grace.xcrysden/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' gnuplot molden grace xcrysden)

# DFT codes
source applications/gromacs.bash
source applications/dftb.bash
source applications/wannier.bash
source applications/gulp.bash
source applications/dftd3.bash
source applications/octopus.bash
source applications/espresso.bash
source applications/elk.bash
# The OpenMX DFT code (has a NEGF routine)
source applications/openmx.bash
source applications/bigdft.bash
source applications/abinit.bash
#source applications/ape.bash

# Needs to be installed AFTER wannier90 :)
source applications/vasp.bash
source applications/vasp-intel.bash
source applications/vasp-potcar.bash

# Specfial photonics applications
source applications/mpb.bash # [gmp,libunistring,guile]
source applications/mpb-serial.bash # [gmp,libunistring,guile]
source applications/meep.bash # [gmp,libunistring,guile]
source applications/meep-serial.bash # [gmp,libunistring,guile]

