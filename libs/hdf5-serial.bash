# Then install HDF5
for p in 1.8.12 ; do

add_package \
    --package hdf5-serial \
    http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$p/src/hdf5-$p.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libhdf5.a

# Add requirments when creating the module
pack_set --module-requirement zlib

tmp="--command-flag --enable-fortran2003"
if $(is_c gnu-4.1) ; then
    unset tmp
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static" \
    --command-flag "--enable-fortran" $tmp

# Make commands
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n- hemera eris) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test
fi
pack_set --command "make install"

done
