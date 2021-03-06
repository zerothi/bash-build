v=2.2.4
add_package -archive pybind11-$v.tar.gz \
	    https://github.com/pybind/pybind11/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set -module-requirement eigen

pack_set -install-query $(pack_get -prefix)/include/pybind11/pybind11.h

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 "-DPYTHON_EXECUTABLE=$(get_parent_exec) .."

pack_cmd "make $(get_make_parallel)"
#pack_cmd "make check > pybind11.tmp"
#pack_store pybind11.test
pack_cmd "make install"
