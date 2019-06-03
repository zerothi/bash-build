set_c intel-13.1.1

#export LANG=en_US.UTF-8
#export LC_ALL=en_US

AR=xiar
RANLIB=ranlib
CC=icc
#CPP="icc -E"
CXX=icpc
#CXXCPP="icpc -E"
#FPP="ifort -E -C -x none"
F77=ifort
F90=ifort
FC=ifort
common_flags="-m64 -fPIC -O3 -xHost -prec-div -prec-sqrt -opt-prefetch"
CFLAGS="$common_flags"
CXXFLAGS="$common_flags"
FCFLAGS="$common_flags"
FFLAGS="$common_flags"

FLAG_OMP="-openmp"
MPICC=mpicc
#MPICPP="mpicc -E"
MPICXX=mpicxx
#MPICXXCPP="mpicxx -E"
MPIFC=mpifort
MPIF77=mpifort
MPIF90=mpifort


INTEL_PATH=/opt/intel/composer_xe_2013.3.163/composerxe
INTEL_LIB="-L$INTEL_PATH/lib/intel64 -Wl,-rpath=$INTEL_PATH/lib/intel64"
MKL_PATH=/opt/intel/composer_xe_2013.3.163/composerxe/mkl
MKL_LIB="-L$MKL_PATH/lib/intel64 -Wl,-rpath=$MKL_PATH/lib/intel64"
export MKL_PATH
export MKL_LIB
export INTEL_PATH
export INTEL_LIB

LDFLAGS=
# Generate default links to libraries
#LDFLAGS="$(list --prefix -L$IBASE_DIR/ compiler/lib/intel64 mkl/lib/intel64) $(list --prefix -Wl,-rpath=$IBASE_DIR/ compiler/lib/intel64 mkl/lib/intel64)"

export FLAG_OMP
export AR
export RANLIB
export CC
export CXX
export CPP
export CXXCPP
export FC
export F77
export F90
export LDFLAGS
export CFLAGS
export FCFLAGS
export FFLAGS
export MPICC
export MPIFC
export MPIF77
export MPIF90
export MKL_PATH
