cloog_v=0.18.1
add_package --build generic \
	    ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$cloog_v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement isl[$isl_v]

pack_set --install-query $(pack_get --prefix)/bin/cloog

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--with-isl=system" \
         "--with-isl-prefix=$(pack_get --prefix isl[$isl_v])" \
         "--with-gmp=system" \
         "--with-gmp-prefix=$(pack_get --prefix gmp[$gmp_v])"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload build-tools"
