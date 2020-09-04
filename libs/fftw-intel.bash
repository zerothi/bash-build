if ! $(is_c intel) ; then
    return 0
fi
add_package -build vendor-intel \
	    -version 3 \
	    fftw_intel-3.local

pack_set -directory .
pack_set -module-requirement fftw[intel]

# Notice that we install this along with fftw2 from intel
# The names are not overlapping, hence we do not need
# to change the version numbering
pack_set -prefix $(pack_get -prefix fftw[intel])

pack_set -install-query $(pack_get -LD)/libfftw3xf.a

# Create the directory (we are not sure that the makefiles will do...)
pack_cmd "mkdir -p $(pack_get -LD)"

# Install the C wrappers (in both precisions)
pack_cmd "cd $MKL_PATH/interfaces/fftw3xc"
pack_cmd "make compiler=intel INSTALL_DIR=$(pack_get -LD) INSTALL_LIBNAME=libfftw3xc libintel64"

# Install the fortran wrappers
# This will be 4 bytes integers
pack_cmd "cd $MKL_PATH/interfaces/fftw3xf"
pack_cmd "make compiler=intel INSTALL_DIR=$(pack_get -LD) INSTALL_LIBNAME=libfftw3xf libintel64"

if [ -d $MKL_PATH/interfaces/fftw3x_cdft ]; then
    pack_cmd "cd $MKL_PATH/interfaces/fftw3x_cdft"
    pack_cmd "module load $(list -mod-names mpi)"

    pack_cmd "make compiler=intel mpi=openmpi mpidir=$(pack_get -prefix mpi)" \
	INSTALL_DIR=$(pack_get -LD) \
	INSTALL_LIBNAME=libfftw3x_cdft libintel64
    
    pack_cmd "module unload $(list -mod-names mpi)"
fi

# create link for include
pack_cmd "cd $(pack_get -prefix)"
pack_cmd "if [ ! -d include ]; then ln -fs $MKL_PATH/include/fftw include ; fi"
