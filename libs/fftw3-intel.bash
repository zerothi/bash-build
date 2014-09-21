if ! $(is_c intel) ; then
    return 0
fi
add_package --build vendor-intel \
    --version 3 \
    fftw_intel-3.local

pack_set --directory .
pack_set --host-reject surt --host muspel --host-reject slid

# Notice that we install this along with fftw2 from intel
# The names are not overlapping, hence we do not need
# to change the version numbering
pack_set --prefix $(pack_get --prefix fftw[intel])

pack_set --install-query $(pack_get --library-path)/libfftw3xf.a

# Create the directory (we are not sure that the makefiles will do...)
pack_set --command "mkdir -p $(pack_get --library-path)"

# Install the C wrappers (in both precisions)
pack_set --command "cd $MKL_PATH/interfaces/fftw3xc"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "install_to=$(pack_get --library-path)" \
    --command-flag "install_as=libfftw3xc.a"
pack_set --command "rm -rf $(pack_get --library-path)/obj*"

# Install the fortran wrappers
# This will be 4 bytes integers
pack_set --command "cd $MKL_PATH/interfaces/fftw3xf"
pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "i8=no fname=a_name_" \
    --command-flag "install_to=$(pack_get --library-path)" \
    --command-flag "install_as=libfftw3xf.a"
pack_set --command "rm -rf $(pack_get --library-path)/obj*"

if [ -d $MKL_PATH/interfaces/fftw3x_cdft ]; then
pack_set --command "cd $MKL_PATH/interfaces/fftw3x_cdft"
pack_set --command "module load $(pack_get --module-name-requirement openmpi) $(pack_get --module-name openmpi)"

pack_set --command "make libintel64" \
    --command-flag "compiler=intel" \
    --command-flag "mpi=openmpi" \
    --command-flag "interface=lp64" \
    --command-flag "INSTALL_DIR=$(pack_get --library-path)"
fi

pack_set --command "module unload $(pack_get --module-name openmpi) $(pack_get --module-name-requirement openmpi)"

pack_set --command "rm -rf $(pack_get --library-path)/obj*"

