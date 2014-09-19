# Now we can install NetCDF (we need the C version to be first added!)
for v in 4.3.2 ; do
add_package http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libnetcdf.a

# Add requirments when creating the module
pack_set $(list --prefix ' --module-requirement ' hdf5 pnetcdf)

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
    --command-flag "--enable-pnetcdf" \
    --command-flag "--enable-netcdf-4"

# Make commands
hv=$(pack_get --version hdf5)
if [ $(vrs_cmp $hv 1.8.12) -gt 0 ]; then
    pack_set --command "sed -i -e 's/H5Pset_fapl_mpiposix/H5Pset_fapl_mpio/gi' ../libsrc4/nc4file.c"
fi

pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test tmp.test.c

# Install the FORTRAN headers
vf=4.4.0
add_package --archive netcdf-fortran-$vf.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v$vf.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --install-prefix $(pack_get --install-prefix netcdf[$v])

# Add requirments when creating the module
pack_set --module-requirement netcdf[$v]

pack_set --install-query $(pack_get --library-path netcdf[$v])/libnetcdff.a

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
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test tmp.test.f

done
