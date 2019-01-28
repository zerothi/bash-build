v=1.13.1
add_package \
    --package h5utils-serial \
    https://github.com/NanoComp/h5utils/releases/download/$v/h5utils-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/h5totxt

pack_set --module-requirement hdf5-serial

pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--without-octave" \
	 "LDFLAGS='$(list --LD-rp +hdf5-serial)'"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > h5utils.test 2>&1"
pack_cmd "make install"
pack_set_mv_test h5utils.test
