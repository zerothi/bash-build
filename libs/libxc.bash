v=2.2.2
add_package http://www.tddft.org/programs/octopus/download/libxc/libxc-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libxc.a

pack_set --command "../configure" \
    --command-flag "--enable-shared" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test


