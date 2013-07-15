v=2.1.24
add_package ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/ncks


# Add requirments when creating the module
pack_set --module-requirement netcdf-serial

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "LDFLAGS='$(list --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

