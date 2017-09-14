v=2.2.1
add_package --archive pybind11-$v.tar.gz \
	    https://github.com/pybind/pybind11/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/include/pybind11/pybind11.h

pack_cmd "module load cmake"

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix) .."
pack_cmd "make $(get_make_parallel)"
#pack_cmd "make check > test.tmp"
#pack_set_mv_test tmp.test
pack_cmd "make install"

pack_cmd "module unload cmake"
