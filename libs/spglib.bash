v=2.0.2
add_package -package spglib \
	    -archive spglib-$v.tar.gz \
	    https://github.com/atztogo/spglib/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -lib -lsymspg

pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -LD)/libsymspg.a

# Install commands that it should run
pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) .."

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > spglib.test 2>&1 || echo 'Forced success'"
pack_cmd "make install"
pack_store spglib.test
