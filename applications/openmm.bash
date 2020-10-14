v=7.4.2
add_package -archive openmm-$v.tar.gz \
	    https://github.com/openmm/openmm/archive/$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/openmm

# CMake should automatically get the include stuff
pack_set -build-mod-req doxygen
pack_set -mod-req fftw

tmp="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
tmp="$tmp -DOPENMM_BUILD_PYTHON_WRAPPERS=OFF"
tmp="$tmp -DDOXYGEN_EXECUTABLE=$(pack_get -prefix doxygen)/bin/doxygen"

pack_cmd "cmake .. $tmp"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
