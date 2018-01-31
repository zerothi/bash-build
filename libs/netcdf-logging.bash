if $(is_host ntch-22) ; then
    v=
else
    return 0
fi

# Now we can install NetCDF (we need the C version to be first added!)
v=4.6.0
add_package --archive netcdf-c-$v.tar.gz \
    --package netcdf-logging \
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
	 "--enable-shared" \
	 "--enable-static" \
	 "--enable-logging" \
	 "--enable-pnetcdf" \
	 "--enable-netcdf-4"

# Make commands
hv=$(pack_get --version hdf5)
if [[ $(vrs_cmp $hv 1.8.12) -gt 0 ]]; then
    pack_cmd "sed -i -e 's/H5Pset_fapl_mpiposix/H5Pset_fapl_mpio/gi' ../libsrc4/nc4file.c"
fi

# Make commands
pack_cmd "make $(get_make_parallel)"
#pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test tmp.test.c

pack_install

# Install the FORTRAN headers
vf=4.4.4
add_package --archive netcdf-fortran-$vf.tar.gz \
	    --package netcdf-fortran-logging \
	    https://github.com/Unidata/netcdf-fortran/archive/v$vf.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set --prefix $(pack_get --prefix netcdf-logging[$v])

# Add requirments when creating the module
pack_set --module-requirement netcdf-logging[$v]

pack_set --install-query $(pack_get --LD)/libnetcdff.a

tmp_cppflags="-DgFortran"

# Install commands that it should run
pack_cmd "../configure" \
	 "CC=${MPICC} CXX=${MPICXX}" \
	 "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
	 "CPPFLAGS='$tmp_cppflags -DLOGGING $CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
	 "LIBS='$(list --LD-rp $(pack_get --mod-req-path)) -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-shared" \
	 "--enable-static"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.f

