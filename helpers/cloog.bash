add_package --build generic \
    ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement build-tools
pack_set --module-requirement isl

pack_set --install-query $(pack_get --prefix)/bin/cloog

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-isl=system" \
    --command-flag "--with-isl-prefix=$(pack_get --prefix isl)" \
    --command-flag "--with-gmp=system" \
    --command-flag "--with-gmp-prefix=$(pack_get --prefix gmp)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test
