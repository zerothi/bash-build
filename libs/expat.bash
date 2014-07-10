v=2.1.0
add_package \
    http://sourceforge.net/projects/expat/files/expat/$v/expat-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libexpat.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test


