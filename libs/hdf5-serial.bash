# Then install HDF5
for p in 1.8.14 ; do

add_package \
    --package hdf5-serial \
    http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$p/src/hdf5-$p.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhdf5.a

# Add requirments when creating the module
pack_set --module-requirement zlib

tmp="--enable-fortran2003"
if $(is_c gnu-4.1) ; then
    unset tmp
fi

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-zlib=$(pack_get --prefix zlib)" \
	 "--enable-shared" \
	 "--enable-static" \
	 "--enable-fortran" $tmp

# Make commands
pack_cmd "make $(get_make_parallel)"
if ! $(is_host n- surt muspel slid) ; then
    pack_cmd "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test
fi
pack_cmd "make install"

done
