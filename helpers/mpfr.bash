add_package --build generic \
    http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement gmp

pack_set --install-query $(pack_get --prefix)/lib/libmpfr.a

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-gmp=$(pack_get --prefix gmp)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "module unload build-tools"
