# The udunits2 package requires an XML library:
#  libcunit
v=2.2.11
add_package ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement expat

pack_set --install-query $(pack_get --prefix)/bin/udunits2

# Install commands that it should run
pack_set \
    --command "./configure" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install install-pdf"
pack_set_mv_test tmp.test


