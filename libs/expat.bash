v=2.4.1
add_package \
    https://vorboss.dl.sourceforge.net/project/expat/expat/$v/expat-$v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libexpat.a

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > expat.test 2>&1"
pack_cmd "make install"
pack_store expat.test


