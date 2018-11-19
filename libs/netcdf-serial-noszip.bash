# Now we can install NetCDF (we need the C version to be first added!)
for v in 4.6.2 ; do
add_package --archive netcdf-c-$v.tar.gz \
    --package netcdf-serial-noszip \
    https://github.com/Unidata/netcdf-c/archive/v$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial-noszip

pack_set --install-query $(pack_get --LD)/libnetcdf.a
pack_set --lib[fortran] -lnetcdff -lnetcdf

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--disable-dap" \
	 "--enable-netcdf-4" \
	 "--enable-shared" \
	 "--enable-static"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 ; echo FORCE"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.c

pack_install 

# Install the FORTRAN headers
vf=4.4.4
add_package --archive netcdf-fortran-$vf.tar.gz \
	    --package netcdf-fortran-serial-noszip \
	    https://github.com/Unidata/netcdf-fortran/archive/v$vf.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

# Add requirments when creating the module
pack_set --module-requirement netcdf-serial-noszip[$v]

pack_set --prefix $(pack_get --prefix netcdf-serial-noszip[$v])

pack_set --install-query $(pack_get --LD)/libnetcdff.a

# Install commands that it should run
pack_cmd "../configure" \
	 "CPPFLAGS='$tmp_cppflags $CPPFLAGS $(list --INCDIRS $(pack_get --mod-req-path))'" \
	 "LIBS='$(list --LD-rp $(pack_get --mod-req-path)) -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-shared" \
	 "--enable-static"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 ; echo FORCE"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.f

done
