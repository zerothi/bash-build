v=1.7
add_package -archive psi4-$v.tar.gz \
	    https://github.com/psi4/psi4/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/psi4

pack_set $(list -prefix '-mod-req ' fftw cython numpy networkx hdf5-serial pybind11 libxc)

tmp=
tmp="$tmp -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
tmp="$tmp -DPYTHON_EXECUTABLE=$(pack_get -prefix python)/bin/python"


tmp="$tmp -DCMAKE_C_COMPILER='$CC'"
tmp="$tmp -DCMAKE_C_FLAGS='$CFLAGS $FLAG_OMP'"
tmp="$tmp -DCMAKE_CXX_COMPILER='$CXX'"
tmp="$tmp -DCMAKE_CXX_FLAGS='$CXXFLAGS $FLAG_OMP'"
tmp="$tmp -DCMAKE_Fortran_COMPILER='$FC'"
tmp="$tmp -DCMAKE_Fortran_FLAGS='$FCFLAGS $FLAG_OMP'"


pack_cmd "cmake .. $tmp"
