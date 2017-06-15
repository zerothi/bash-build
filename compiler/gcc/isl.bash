isl_v=0.18
add_package --build generic \
	    http://isl.gforge.inria.fr/isl-$isl_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement gmp[$gmp_v]

pack_set --install-query $(pack_get --prefix)/lib/libisl.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--with-gmp-prefix=$(pack_get --prefix gmp[$gmp_v])"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload build-tools"
