v=4.4.6
add_package http://nco.sourceforge.net/src/nco-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ncks

# Add requirments when creating the module
# udunits depend on NetCDF
pack_set --module-requirement gsl \
    --module-requirement udunits \
    --module-requirement netcdf-serial

pack_set $(list -p '--host-reject ' hemera eris ponto)

# Install commands that it should run
pack_set \
    --command "./configure" \
    --command-flag "LIBS=' -lgsl -lgslcblas -lm -ludunits2 -lexpat -lnetcdf '" \
    --command-flag "CPPFLAGS=' $(list --INCDIRS $(pack_get --mod-req-path)) '" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-udunits2" \
    --command-flag "--enable-gsl"

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
#pack_set_mv_test tmp.test

