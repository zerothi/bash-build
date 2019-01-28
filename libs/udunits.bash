# The udunits2 package requires an XML library:
#  libcunit
v=2.2.24
add_package ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement expat

pack_set --install-query $(pack_get --prefix)/bin/udunits2

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > udunits.test 2>&1"
pack_cmd "make install install-pdf"
pack_set_mv_test udunits.test


