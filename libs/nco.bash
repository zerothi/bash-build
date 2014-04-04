v=4.4.3
add_package http://dust.ess.uci.edu/nco/src/nco-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/ncks

# Add requirments when creating the module
# udunits depend on NetCDF
pack_set --module-requirement gsl \
    --module-requirement udunits \
    --module-requirement netcdf-serial

# Install commands that it should run
pack_set \
    --command "./configure" \
    --command-flag "LDFLAGS=' $(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement)) '" \
    --command-flag "LIBS=' -lgsl -lgslcblas -lm -ludunits2 -lexpat -lnetcdf '" \
    --command-flag "CPPFLAGS=' $(list --INCDIRS $(pack_get --module-paths-requirement)) '" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-udunits2" \
    --command-flag "--enable-gsl"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

