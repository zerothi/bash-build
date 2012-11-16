#source libs/gmp.bash
#source libs/guile.bash

# Library used by MANY packages
source libs/openmpi.bash

# Default fftw libs
source libs/fftw2.bash
source libs/fftw3.bash

# Default packages for many libs
source libs/blas.bash
source libs/lapack.bash
source libs/atlas.bash

# A sparse library
source libs/suitesparse_config.bash
source libs/camd.bash
source libs/amd.bash
source libs/colamd.bash
source libs/ccolamd.bash
source libs/cholmod.bash
source libs/umfpack.bash

# Some specific libraries
source libs/gsl.bash
#source libs/boost.bash
source libs/ctl.bash
source libs/harminv.bash


source libs/zlib.bash
source libs/scalapack.bash
source libs/hdf5.bash
source libs/hdf5-serial.bash
source libs/parallel-netcdf.bash
source libs/netcdf.bash
source libs/netcdf-serial.bash
