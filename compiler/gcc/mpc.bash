mpc_v=1.1.0
add_package --build generic \
	    ftp://ftp.gnu.org/gnu/mpc/mpc-$mpc_v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement mpfr[$mpfr_v]

pack_set --install-query $(pack_get --prefix)/lib/libmpc.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--with-gmp=$(pack_get --prefix gmp[$gmp_v])" \
         "--with-mpfr=$(pack_get --prefix mpfr[$mpfr_v])"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload build-tools"
