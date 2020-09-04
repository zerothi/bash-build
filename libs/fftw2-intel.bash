if ! $(is_c intel) ; then
    return 0
fi
add_package -build vendor-intel \
	    -package fftw \
	    -version intel fftw-2.local

pack_set -directory .

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libfftw2xf_DOUBLE.a

# Create the directory (we are not sure that the makefiles will do...)
pack_cmd "mkdir -p $(pack_get -LD)"

# Install the C wrappers (in both precisions)
pack_cmd "cd $MKL_PATH/interfaces/fftw2xc"
pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "INSTALL_DIR=$(pack_get -LD)" \
	 "INSTALL_LIBNAME=libfftw2xc_SINGLE.a" \
	 "PRECISION=MKL_SINGLE"
pack_cmd "rm -rf $(pack_get -LD)/obj*"

pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "INSTALL_DIR=$(pack_get -LD)" \
	 "INSTALL_LIBNAME=libfftw2xc_DOUBLE.a" \
	 "PRECISION=MKL_DOUBLE"
pack_cmd "rm -rf $(pack_get -LD)/obj*"

# Install the fortran wrappers
pack_cmd "cd $MKL_PATH/interfaces/fftw2xf"
pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "i8=no" \
	 "INSTALL_DIR=$(pack_get -LD)" \
	 "INSTALL_LIBNAME=libfftw2xf_SINGLE.a" \
	 "PRECISION=MKL_SINGLE"
pack_cmd "rm -rf $(pack_get -LD)/obj*"
pack_cmd "make libintel64" \
	 "compiler=intel" \
	 "i8=no" \
	 "INSTALL_DIR=$(pack_get -LD)" \
	 "INSTALL_LIBNAME=libfftw2xf_DOUBLE.a" \
	 "PRECISION=MKL_DOUBLE"
pack_cmd "rm -rf $(pack_get -LD)/obj*"

if [[ -d $MKL/interfaces/fftw2x_cdft ]]; then
    pack_cmd "cd $MKL_PATH/interfaces/fftw2x_cdft"
    pack_cmd "module load $(list -mod-names mpi)"
    pack_cmd "make libintel64" \
	     "compiler=intel" \
	     "mpi=openmpi" \
	     "interface=lp64" \
	     "INSTALL_DIR=$(pack_get -LD)" \
	     "PRECISION=MKL_SINGLE"
    pack_cmd "rm -rf $(pack_get -LD)/obj*"

    pack_cmd "make libintel64" \
	     "compiler=intel" \
	     "mpi=openmpi" \
	     "interface=lp64" \
	     "INSTALL_DIR=$(pack_get -LD)" \
	     "PRECISION=MKL_DOUBLE"
    pack_cmd "rm -rf $(pack_get -LD)/obj*"
    pack_cmd "module unload $(list -mod-names mpi)"
fi


# Install a link to the include files
pack_cmd "cd $(pack_get -prefix)"
pack_cmd "[ ! -d include ] && ln -fs $MKL_PATH/include/fftw include"
