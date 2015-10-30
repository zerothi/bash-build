# First install zlib, which is a simple library
add_package http://zlib.net/zlib-1.2.8.tar.gz 

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libz.a
pack_set --lib -lz

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test
