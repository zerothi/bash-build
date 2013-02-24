# Now we can install NetCDF (we need the C version to be first added!)
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.2.1.1.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --alias netcdf-serial
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdf.a

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-dap" \
    --command-flag "--enable-static" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"



# Install the FORTRAN headers
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# Add requirments when creating the module
pack_set --module-requirement netcdf-serial

pack_set --alias netcdf-fortran-serial

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias netcdf-serial)/$(pack_get --version netcdf-serial)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdff.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --module-requirement))'" \
    --command-flag "LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement)) -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

