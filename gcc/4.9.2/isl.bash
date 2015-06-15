add_package --build generic \
    ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement gmp[6.0.0a]

pack_set --install-query $(pack_get --prefix)/lib/libisl.a

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-gmp-prefix=$(pack_get --prefix gmp[6.0.0a])"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "module unload build-tools"
