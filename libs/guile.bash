add_package ftp://ftp.gnu.org/gnu/guile/guile-2.0.6.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libguile.a

pack_set --module-requirement gmp

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test


