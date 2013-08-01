if [ ! -z "$MKL_PATH" ] ; then
add_package fftw-2.local

pack_set --version intel
pack_set --directory .
pack_set --host-reject surt

pack_set --prefix-and-module $(pack_get --package)/$(pack_get --version)/$(get_c)
pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw2xf_DOUBLE.a

# Create the directory (we are not sure that the makefiles will do...)
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"

# Install the C wrappers (in both precisions)
pack_set --command "cd $MKL_PATH/interfaces/fftw2xc"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "INSTALL_LIBNAME=libfftw2xc_SINGLE.a" \
    --command-flag "PRECISION=MKL_SINGLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "INSTALL_LIBNAME=libfftw2xc_DOUBLE.a" \
    --command-flag "PRECISION=MKL_DOUBLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

# Install the fortran wrappers
pack_set --command "cd $MKL_PATH/interfaces/fftw2xf"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "i8=no" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "INSTALL_LIBNAME=libfftw2xf_SINGLE.a" \
    --command-flag "PRECISION=MKL_SINGLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "i8=no" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "INSTALL_LIBNAME=libfftw2xf_DOUBLE.a" \
    --command-flag "PRECISION=MKL_DOUBLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

pack_set --command "cd $MKL_PATH/interfaces/fftw2x_cdft"
pack_set --command "module load $(pack_get --module-requirement openmpi) $(pack_get --module-name openmpi)"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "mpi=openmpi" \
    --command-flag "interface=lp64" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "PRECISION=MKL_SINGLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "mpi=openmpi" \
    --command-flag "interface=lp64" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib" \
    --command-flag "PRECISION=MKL_DOUBLE"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

pack_set --command "module unload $(pack_get --module-name openmpi) $(pack_get --module-requirement openmpi)"

# Install a link to the include files
pack_set --command "cd $(pack_get --install-prefix)"
# Needs to be a softlink!
pack_set --command "ln -fs $MKL_PATH/include/fftw include"

fi
