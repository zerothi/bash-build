add_package --build generic \
    ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement mpfr

pack_set --install-query $(pack_get --prefix)/lib/libmpc.a

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-gmp=$(pack_get --prefix gmp)" \
    --command-flag "--with-mpfr=$(pack_get --prefix mpfr)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "module unload build-tools"
