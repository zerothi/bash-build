return 0
if $(is_host zerothi) ; then
    v=
else
    return 0
fi

# Now we can install NetCDF (we need the C version to be first added!)
v=4.3.1
add_package \
    --package netcdf-logging \
    http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdf.a

# Add requirments when creating the module
pack_set --module-requirement hdf5 \
    --module-requirement pnetcdf


# bugfix for the iter test!
pack_set \
    --command "sed -i -e 's|CC ./iter.c -o.*|CC ./iter.c -o iter.exe \$CFLAGS \$LDFLAGS|g' ../ncdump/tst_iter.sh"

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-dap" \
    --command-flag "--disable-shared" \
    --command-flag "--enable-static" \
    --command-flag "--enable-logging" \
    --command-flag "--enable-pnetcdf" \
    --command-flag "--enable-netcdf-4"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

pack_set --command "mv tmp.test $(pack_get --install-prefix)/"


# Install the FORTRAN headers
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --install-prefix $(pack_get --install-prefix netcdf-logging)

# Add requirments when creating the module
pack_set --module-requirement netcdf-logging

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdff.a

tmp_cppflags="-DgFortran"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --module-paths-requirement))'" \
    --command-flag "LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement)) -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-shared" \
    --command-flag "--enable-static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

