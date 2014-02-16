# The udunits2 package requires an XML library:
#  libcunit
v=2.2.4
add_package --package udunits --version $v \
	ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-$v-Source.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-requirement expat

pack_set --install-query $(pack_get --install-prefix)/bin/udunits2

# apparently they have it in a tar file there
pack_set --command "tar xfz udunits-2.2.4.tar.gz"
pack_set --command "cd udunits-2.2.4"

# Install commands that it should run
pack_set \
    --command "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install install-pdf"
pack_set --command "mv tmp.test $(pack_get --install-prefix)/"


