# Now we can install NetCDF (we need the C version to be first added!)
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.2.1.1.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdf.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-shared" \
    --command-flag "--enable-static" \
    --command-flag "--enable-pnetcdf" \
    --command-flag "--enable-netcdf-4"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"




# Install the FORTRAN headers
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz

pack_set --alias netcdf
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version netcdf)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdff.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF77} F90=${MPIF90} FC=${MPIFC}" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"
