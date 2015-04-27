add_package --build generic \
    ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement isl[0.12.2]

pack_set --install-query $(pack_get --prefix)/bin/cloog

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-isl=system" \
    --command-flag "--with-isl-prefix=$(pack_get --prefix isl[0.12.2])" \
    --command-flag "--with-gmp=system" \
    --command-flag "--with-gmp-prefix=$(pack_get --prefix gmp[6.0.0a])"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "module unload build-tools"
