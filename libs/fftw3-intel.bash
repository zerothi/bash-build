if [ ! -z "$MKL_PATH" ] ; then
add_package fftw_intel-3.local

pack_set --directory .
pack_set --version 3
pack_set --install-prefix $(pack_get --install-prefix fftw[intel])

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw3xf.a

# Create the directory (we are not sure that the makefiles will do...)
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"

# Install the C wrappers (in both precisions)
pack_set --command "cd $MKL_PATH/interfaces/fftw3xc"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "install_to=$(pack_get --install-prefix)/lib" \
    --command-flag "install_as=libfftw3xc.a"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

# Install the fortran wrappers
# This will be 4 bytes integers
pack_set --command "cd $MKL_PATH/interfaces/fftw3xf"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "i8=no fname=a_name_" \
    --command-flag "install_to=$(pack_get --install-prefix)/lib" \
    --command-flag "install_as=libfftw3xf.a"
pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

pack_set --command "cd $MKL_PATH/interfaces/fftw3x_cdft"
pack_set --command "module load $(get_default_modules) $(pack_get --module-name openmpi)"

pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "mpi=openmpi" \
    --command-flag "interface=lp64" \
    --command-flag "INSTALL_DIR=$(pack_get --install-prefix)/lib"

pack_set --command "module unload $(pack_get --module-name openmpi) $(get_default_modules)"

pack_set --command "rm -rf $(pack_get --install-prefix)/lib/obj"

fi