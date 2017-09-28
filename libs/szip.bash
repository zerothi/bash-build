add_package https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libsz.a
pack_set --lib -lsz

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test
