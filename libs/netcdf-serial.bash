# Now we can install NetCDF (we need the C version to be first added!)
for v in 4.3.3 ; do
add_package \
    --package netcdf-serial \
    http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial

pack_set --install-query $(pack_get --LD)/libnetcdf.a

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--disable-dap" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test tmp.test.c


# Install the FORTRAN headers
vf=4.4.1
add_package --archive netcdf-fortran-$vf.tar.gz \
    --package netcdf-fortran-serial \
    https://github.com/Unidata/netcdf-fortran/archive/v$vf.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# Add requirments when creating the module
pack_set --module-requirement netcdf-serial[$v]

pack_set --prefix $(pack_get --prefix netcdf-serial[$v])

pack_set --install-query $(pack_get --LD)/libnetcdff.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
    --command-flag "LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --mod-req-path)) -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--enable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test tmp.test.f

done
