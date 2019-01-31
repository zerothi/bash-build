msg_install --message "Installing the applications..."

# Make all default modules
build_set --default-setting $IS_MODULE
build_set --default-setting $CRT_DEF_MODULE

# Analysis tools
source_pack applications/bader.bash

source_pack applications/plumed.bash

# Pseudo potential generation
source_pack applications/atom.bash
source_pack applications/ape.bash
source_pack applications/oncvpsp.bash
source_pack applications/getfem.bash

source_pack applications/siesta.bash
source_pack applications/siesta-dev.bash # my old ts-development
source_pack applications/siesta-trunk.bash # siesta trunk development
source_pack applications/siesta-trunk-debug.bash
source_pack applications/siesta-bulk-bias.bash # siesta trunk development
source_pack applications/fhiaims.bash

source_pack applications/lammps.bash

# Graphics applications
source_pack applications/gnuplot.bash
source_pack applications/molden.bash
source_pack applications/xmgrace.bash
source_pack applications/xcrysden.bash
source_pack applications/vesta.bash
source_pack applications/vmd.bash
# Currently VTK is an API not used anywhere, hence we do not install it
#source_pack applications/vtk.bash
# Installed by source to get python support
source_pack applications/vmd-python.bash
source_pack applications/gdis.bash
source_pack applications/povray.bash
source_pack applications/getfem.bash

source_pack applications/octave.bash

# Specfial photonics applications
source_pack applications/mpb.bash # [gmp,libunistring,guile]
source_pack applications/meep.bash # [gmp,libunistring,guile]

# Create a module with default all plotting tools
tmp=
for i in gnuplot molden grace xcrysden vmd povray gdis
do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    --module-path $(build_get --module-path)-apps \
    -n "Script for loading different graphical tools: $(get_c)" \
    -v 1.0 \
    -M graphics \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)

# DFT codes
source_pack applications/gromacs.bash
source_pack applications/dftb.bash
source_pack applications/dftb_slako.bash
source_pack applications/wannier.bash
source_pack applications/gulp.bash
source_pack applications/dftd3.bash
source_pack applications/espresso.bash
source_pack applications/elk.bash
source_pack applications/openmx.bash
source_pack applications/bigdft.bash
source_pack applications/abinit.bash

# Needs to be installed AFTER wannier90 :)
source applications/vasp/vasp.bash
source_pack applications/vasp-potcar.bash

source_pack applications/bgw.bash
source_pack applications/cp2k.bash

# Requires bgw
source_pack applications/octopus.bash

source_pack applications/atk.bash

# analysis tools
source_pack applications/otf2.bash
source_pack applications/opari2.bash
source_pack applications/papi.bash
source_pack applications/bsc-perf-tools.bash
source_pack applications/valgrind.bash
source_pack applications/scorep.bash
source_pack applications/tau.bash
source_pack applications/scalasca.bash


build_set --remove-default-setting module
