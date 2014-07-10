add_package ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libgmp.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

