#source applications/git.bash
source applications/lammps.bash
source applications/gnuplot.bash
source applications/molden.bash
source applications/xmgrace.bash
source applications/xcrysden.bash

source applications/dftb.bash
source applications/qespresso.bash
source applications/mpb.bash # [gmp,libunistring,guile]
source applications/mpb-serial.bash # [gmp,libunistring,guile]
source applications/meep.bash # [gmp,libunistring,guile]
source applications/meep-serial.bash # [gmp,libunistring,guile]
source applications/wannier.bash

source applications/gulp.bash


# Create a module with default all plotting tools
create_module \
    --module-path $install_path/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading GUI: $(get_c)\"" \
    -v $(pack_get --version) \
    -M gnuplot.molden.xmgrace.xcrysden/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' gnuplot molden $(pack_get --module-requirement grace) grace $(pack_get --module-requirement xcrysden) xcrysden)
