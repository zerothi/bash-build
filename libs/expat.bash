v=2.1.0
add_package \
    http://sourceforge.net/projects/expat/files/expat/$v/expat-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libexpat.a

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test


