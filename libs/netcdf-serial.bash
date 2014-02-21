# Now we can install NetCDF (we need the C version to be first added!)
for v in 4.3.1.1 ; do
add_package \
    --package netcdf-serial \
    http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdf.a

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-dap" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

#pack_set --command "mv tmp.test $(pack_get --install-prefix)/tmp.test.c"


# Install the FORTRAN headers
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# Add requirments when creating the module
pack_set --module-requirement netcdf-serial

pack_set --alias netcdf-fortran-serial

pack_set --install-prefix $(pack_get --install-prefix netcdf-serial)

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdff.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --module-paths-requirement))'" \
    --command-flag "LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement)) -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

#pack_set --command "mv tmp.test $(pack_get --install-prefix)/tmp.test.f"

done
