v=7.4.2
add_package -archive openmm-$v.tar.gz \
	    https://github.com/openmm/openmm/archive/$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/lib/libOpenMM.so

# CMake should automatically get the include stuff
if [[ $(pack_installed doxygen) -eq 1 ]]; then
    pack_set -build-mod-req doxygen
    tmp="-DDOXYGEN_EXECUTABLE=$(pack_get -prefix doxygen)/bin/doxygen"
elif [[ -e /appl/doxygen/1.8.20/bin/doxygen ]]; then
    tmp="-DDOXYGEN_EXECUTABLE=/appl/doxygen/1.8.20/bin/doxygen"
else
    # NO DOXYGEN!
    pack_set -host-reject $(get_hostname)
fi
pack_set -mod-req fftw
pack_set -mod-req python
pack_set -mod-req numpy
# only for Amber netcdf files
pack_set -mod-req scipy
_swig_v=4
pack_set -mod-req swig[$_swig_v]

tmp="$tmp -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
tmp="$tmp -DOPENMM_BUILD_PYTHON_WRAPPERS=ON"
tmp="$tmp -DPYTHON_EXECUTABLE=$(pack_get -prefix python)/bin/python"
tmp="$tmp -DSWIG_EXECUTABLE=$(pack_get -prefix swig[$_swig_v])/bin/swig"

# Fix python installation!
pack_cmd "sed -i -e 's|--root=|--prefix=$(pack_get -prefix) --root=|' ../wrappers/python/CMakeLists.txt"

pack_cmd "cmake .. $tmp"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install PythonInstall"
pack_cmd "make test > openmm.test 2>&1 || echo forced"
pack_store openmm.test
