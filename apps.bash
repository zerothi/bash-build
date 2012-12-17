#source applications/git.bash
msg_install --message "Installing the applications..."

source applications/siesta-stable.bash
source applications/siesta-dev.bash

timings For SIESTA installation

source applications/lammps.bash

# Graphics applications
source applications/gnuplot.bash
source applications/molden.bash
source applications/xmgrace.bash
source applications/xcrysden.bash

timings For GUI plots installation

source applications/dftb.bash
source applications/qespresso.bash
source applications/wannier.bash
source applications/gulp.bash

timings For requested dynamics/DFT codes

# Specfial photonics applications
source applications/mpb.bash # [gmp,libunistring,guile]
source applications/mpb-serial.bash # [gmp,libunistring,guile]
source applications/meep.bash # [gmp,libunistring,guile]
source applications/meep-serial.bash # [gmp,libunistring,guile]

timings For Photonics group installation


# Create a module with default all plotting tools
create_module \
    --module-path $(get_installation_path)/modules-npa \
    -n "\"Nick Papior Andersen's script for loading GUI: $(get_c)\"" \
    -v $(pack_get --version) \
    -M gnuplot.molden.grace.xcrysden/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement gnuplot) gnuplot) \
    $(list --prefix '-L ' $(pack_get --module-requirement molden) molden) \
    $(list --prefix '-L ' $(pack_get --module-requirement grace) grace) \
    $(list --prefix '-L ' $(pack_get --module-requirement xcrysden) xcrysden)
