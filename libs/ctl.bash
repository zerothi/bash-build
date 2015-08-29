# We will only install this on the super computer
add_package http://ab-initio.mit.edu/libctl/libctl-3.2.1.tar.gz

pack_set $(list --prefix "--host-reject " ntch zeroth)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libctl.a

# Install commands that it should run
pack_cmd "LIBS='-lm' ./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

