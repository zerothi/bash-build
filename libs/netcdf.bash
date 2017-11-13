# Now we can install NetCDF (we need the C version to be first added!)
for v in 4.5.0 ; do
add_package --archive netcdf-c-$v.tar.gz \
    --package netcdf \
    https://github.com/Unidata/netcdf-c/archive/v$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libnetcdf.a
pack_set --lib[fortran] -lnetcdff -lnetcdf

# Add requirments when creating the module
pack_set $(list --prefix ' --module-requirement ' hdf5 pnetcdf)

# bugfix for the iter test!
pack_cmd "sed -i -e 's|CC ./iter.c -o.*|CC ./iter.c -o iter.exe \$CFLAGS \$LDFLAGS|g' ../ncdump/tst_iter.sh"

# Install commands that it should run
pack_cmd "../configure" \
     "CC=${MPICC} CXX=${MPICXX}" \
     "--prefix=$(pack_get --prefix)" \
     "--disable-dap" \
     "$(list --prefix --enable- shared static pnetcdf netcdf-4 parallel-tests)"


# Make commands
hv=$(pack_get --version hdf5)
if [[ $(vrs_cmp $hv 1.8.12) -gt 0 ]]; then
    pack_cmd "sed -i -e 's/H5Pset_fapl_mpiposix/H5Pset_fapl_mpio/gi' ../libsrc4/nc4file.c"
fi

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 ; echo FORCE"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.c

pack_install

###############################
#                             #
# Install the FORTRAN headers #
###############################
vf=4.4.4
add_package --archive netcdf-fortran-$vf.tar.gz \
    --package netcdf-fortran \
    https://github.com/Unidata/netcdf-fortran/archive/v$vf.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --prefix $(pack_get --prefix netcdf[$v])

# Add requirments when creating the module
pack_set --module-requirement netcdf[$v]

pack_set --install-query $(pack_get --LD)/libnetcdff.a

tmp_cppflags="-DgFortran"

# Install commands that it should run
pack_cmd "../configure" \
     "CC=${MPICC} CXX=${MPICXX}" \
     "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
     "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
     "LIBS='$(list --LD-rp $(pack_get --mod-req-path)) -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
     "--prefix=$(pack_get --prefix)" \
     "$(list --prefix --enable- shared static parallel-tests)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 ; echo FORCE"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.f

done
