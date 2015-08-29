# Then install H5 utils
for p in 1.12.1 ; do

add_package \
    --package h5utils-serial \
    http://ab-initio.mit.edu/h5utils/h5utils-$p.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/h5totxt

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--without-octave" \
	 "LDFLAGS='$(list --LD-rp +hdf5-serial)'"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

done
