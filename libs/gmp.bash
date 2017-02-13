add_package https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libgmp.a

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

