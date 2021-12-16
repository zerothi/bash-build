# First install zlib, which is a simple library
add_package -package zlib -archive $(pack_get -archive gen-zlib) \
	    $(pack_get -url gen-zlib)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libz.a
pack_set -lib -lz

# Install commands that it should run
pack_cmd "./configure" \
	 --zlib-compat --64 \
	 --native \
	 "--prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > zlib.test 2>&1"
pack_cmd "make install"
pack_store zlib.test
