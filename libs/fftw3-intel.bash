if ! $(is_c intel) ; then
    return 0
fi
add_package --build vendor-intel \
	    --version 3 \
	    fftw_intel-3.local

pack_set --directory .
pack_set --module-requirement fftw[intel]

# Notice that we install this along with fftw2 from intel
# The names are not overlapping, hence we do not need
# to change the version numbering
pack_set --prefix $(pack_get --prefix fftw[intel])

pack_set --install-query $(pack_get --LD)/libfftw3xf.a

# Create the directory (we are not sure that the makefiles will do...)
pack_cmd "mkdir -p $(pack_get --LD)"

# Install the C wrappers (in both precisions)
pack_cmd "cd $MKL_PATH/interfaces/fftw3xc"
pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "install_to=$(pack_get --LD)" \
	 "install_as=libfftw3xc.a"
pack_cmd "rm -rf $(pack_get --LD)/obj*"

# Install the fortran wrappers
# This will be 4 bytes integers
pack_cmd "cd $MKL_PATH/interfaces/fftw3xf"
pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "i8=no fname=a_name_" \
	 "install_to=$(pack_get --LD)" \
	 "install_as=libfftw3xf.a"
pack_cmd "rm -rf $(pack_get --LD)/obj*"

if [ -d $MKL_PATH/interfaces/fftw3x_cdft ]; then
    pack_cmd "cd $MKL_PATH/interfaces/fftw3x_cdft"
    pack_cmd "module load $(pack_get --module-name-requirement mpi) $(pack_get --module-name mpi)"

    pack_cmd "make libintel64" \
	     "compiler=intel" \
	     "mpi=openmpi" \
	     "interface=lp64" \
	     "INSTALL_DIR=$(pack_get --LD)"
fi

pack_cmd "module unload $(pack_get --module-name mpi) $(pack_get --module-name-requirement mpi)"

pack_cmd "rm -rf $(pack_get --LD)/obj*"

# create link for include
pack_cmd "cd $(pack_get --prefix)"
pack_cmd "if [ ! -d include ]; then ln -fs $MKL_PATH/include/fftw include ; fi"
