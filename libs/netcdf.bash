# Now we can install NetCDF (we need the C version to be first added!)
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.2.1.1.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdf.a

# Add requirments when creating the module
pack_set \
    --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement parallel-netcdf


# bugfix for the iter test!
pack_set \
    --command "sed -i -e 's|CC ./iter.c -o.*|CC ./iter.c -o iter.exe \$CFLAGS \$LDFLAGS|g' ../ncdump/tst_iter.sh"

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --module-requirement))'" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "CFLAGS='$CFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
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

pack_install


# Install the FORTRAN headers
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz

pack_set --alias netcdf
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version netcdf)/$(get_c)

# Add requirments when creating the module
pack_set \
    --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement parallel-netcdf \
    --module-requirement netcdf

pack_set --install-query $(pack_get --install-prefix)/lib/libnetcdff.a

tmp=$(pack_get --install-prefix hdf5)/lib/libhdf5
# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "CPPFLAGS='$CPPFLAGS $(list --INCDIRS $(pack_get --module-requirement netcdf))/include -DgFortran'" \
    --command-flag "CFLAGS='$CFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "FCFLAGS='$FCFLAGS $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement)) -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lcurl'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--disable-shared" \
    --command-flag "--enable-static"
#    --command-flag "FCFLAGS='$FCFLAGS $(pack_get --install-prefix netcdf)/lib/libnetcdf.a'" \

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
