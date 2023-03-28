v=5.1.5
add_package -archive nco-$v.tar.gz \
	    https://github.com/nco/nco/archive/refs/tags/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ncks

# Add requirments when creating the module
# udunits depend on NetCDF
pack_set --module-requirement gsl \
	 --module-requirement udunits \
	 --module-requirement netcdf-serial

# Install commands that it should run
pack_cmd "./configure" \
	 "LIBS=' -lgsl -lgslcblas -lm -ludunits2 -lexpat -lnetcdf '" \
	 "CPPFLAGS=' $(list --INCDIRS $(pack_get --mod-req-path)) '" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-netcdf-4" \
	 "--enable-openmp" \
	 "--enable-dap" \
	 "--enable-udunits2" \
	 "--enable-gsl"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > nco.test 2>&1"
pack_cmd "make install"
pack_store nco.test

