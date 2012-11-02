# Install the Parallel NetCDF (requires bison)
add_package http://ftp.mcs.anl.gov/pub/parallel-netcdf/parallel-netcdf-1.3.1.tar.bz2

pack_set --alias pnetcdf
pack_set -s $BUILD_DIR -s $CONFIGURE -s $MAKE_TESTS -s $MAKE_INSTALL \
    -s $IS_MODULE -s $LOAD_MODULE
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --install-query $(pack_get --install-prefix)/lib/libpnetcdf.a
pack_set --module-name $(pack_get --alias)/$(pack_get --version)/$(get_c)