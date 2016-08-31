set_c pgi-13.10-0

AR=ar
RANLIB=ranlib
CC=pgcc
CXX=pgcpp
#CPP="gcc -E"
#CXXCPP="g++ -E"
F77=pgf77
F90=pgf95
FC=pgf95
common_flags="-m64 -fPIC -O3 -Munroll -Mvect=prefetch -Mnofpapprox -Mnofprelaxed"
CFLAGS="$common_flags"
CXXFLAGS="$common_flags"
FCFLAGS="$common_flags -Mnosecond_underscore"
FFLAGS="$common_flags -Mnosecond_underscore"

FLAG_OMP="-mp"
MPICC=mpicc
#MPICPP="mpicc -E"
MPICXX=mpicxx
#MPICXXCPP="mpicxx -E"
MPIFC=mpif90
MPIF77=mpif77
MPIF90=mpif90

LDFLAGS=

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
