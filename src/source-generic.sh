set_c gnu-$gen_gnu_version

AR=ar
CC=gcc
CXX=g++
#CPP="gcc -E"
#CXXCPP="g++ -E"
F77=gfortran
F90=gfortran
FC=gfortran
common_flags="-m64 -fPIC -O2"
CFLAGS="$common_flags"
CXXFLAGS="$common_flags"
FCFLAGS="$common_flags -fno-second-underscore"
FFLAGS="$common_flags -fno-second-underscore"

CPPFLAGS="$common_flags"

FLAG_OMP="-fopenmp"
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
export MPICXX
export MPIFC
export MPIF77
export MPIF90
export FLAG_OMP
