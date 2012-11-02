# Then install HDF5
add_package http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.9.tar.gz

pack_set -s $BUILD_DIR -s $CONFIGURE -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query \
    $(pack_get --install-prefix)/lib/libhdf5.a
