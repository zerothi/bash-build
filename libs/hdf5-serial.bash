# Then install HDF5
add_package http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.9.tar.gz

pack_set --alias hdf5-serial

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libhdf5.a

# Add requirments when creating the module
pack_set --module-requirement zlib

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static" \
    --command-flag "--enable-fortran" \
    --command-flag "--enable-fortran2003"

# Make commands
pack_set --command "make $(get_make_parallel)"
# make check fails due to a bug in the test suite....
pack_set --command "make" \
    --command-flag "install"

pack_install
