source $BBUILD_DIR/2023-aug/source-nvhpc-version.sh
set_c nvhpc-$nvhpc_v

#CPP="nvc -E "
#CXXCPP="nvc++ -E"
#FPP="nvfortran -cpp -E -C -x none"

common_flags="-tp host -fPIC -O3 -Munroll,vect,prefetch,simd"
CFLAGS="$common_flags"
CXXFLAGS="$common_flags"
#CPPFLAGS="$common_flags"
FCFLAGS="$common_flags -Mnosecond_underscore"
FFLAGS="$FCFLAGS"

FLAG_OMP="-mp"
FLAG_ACC="-acc"
MPICC=mpicc
#MPICPP="mpicc -E"
MPICXX=mpicxx
#MPICXXCPP="mpicxx -E"
MPIFC=mpifort
MPIF77=mpifort
MPIF90=mpifort

LDFLAGS=

export FLAG_OMP
export FLAG_ACC
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
export CXXFLAGS
export FCFLAGS
export FFLAGS
export MPICC
export MPIFC
export MPIF77
export MPIF90
