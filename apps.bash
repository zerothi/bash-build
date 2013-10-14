#source applications/git.bash
msg_install --message "Installing the applications..."

source applications/siesta-stable.bash
source applications/siesta-dev.bash
source applications/siesta-mattias.bash
source applications/siesta-scf.bash

source applications/lammps.bash

# Graphics applications
source applications/gnuplot.bash
source applications/molden.bash
source applications/xmgrace.bash
source applications/xcrysden.bash
source applications/vmd.bash
source applications/vmd-text.bash

# DFT codes
source applications/dftb.bash
source applications/qespresso.bash
source applications/wannier.bash
source applications/gulp.bash

# Needs to be installed AFTER wannier90 :)
source applications/vasp.bash
source applications/vasp-intel.bash
source applications/vasp-potcar.bash

# Specfial photonics applications
source applications/mpb.bash # [gmp,libunistring,guile]
source applications/mpb-serial.bash # [gmp,libunistring,guile]
source applications/meep.bash # [gmp,libunistring,guile]
source applications/meep-serial.bash # [gmp,libunistring,guile]

# Create a module with default all plotting tools
create_module \
    --module-path $(build_get --module-path)-npa \
    -n "Nick Papior Andersen's script for loading GUI: $(get_c)" \
    -v $(pack_get --version) \
    -M gnuplot.molden.grace.xcrysden/$(get_c) \
    -P "/directory/should/not/exist" \
    -RL gnuplot \
    $(list --prefix '-RL ' molden grace xcrysden)

#source applications/gdis.bash
source applications/povray.bash

