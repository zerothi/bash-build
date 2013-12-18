set_c gnu-4.7.2

AR=ar
CC=gcc
CXX=g++
#CPP="gcc -E"
#CXXCPP="g++ -E"
F77=gfortran
F90=gfortran
FC=gfortran
common_flags="-m64 -fPIC -O3 -ftree-vectorize -fexpensive-optimizations -funroll-loops -fprefetch-loop-arrays"
CFLAGS="$common_flags"
CPPFLAGS="$common_flags"
FCFLAGS="$common_flags -fno-second-underscore"
FFLAGS="$common_flags -fno-second-underscore"

MPICC=mpicc
#MPICPP="mpicc -E"
MPICXX=mpicxx
#MPICXXCPP="mpicxx -E"
MPIFC=mpif90
MPIF77=mpif77
MPIF90=mpif90

LDFLAGS=

export AR
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
