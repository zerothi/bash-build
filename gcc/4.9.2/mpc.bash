add_package --build generic \
	    ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement mpfr[3.1.2]

pack_set --install-query $(pack_get --prefix)/lib/libmpc.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--with-gmp=$(pack_get --prefix gmp[6.0.0a])" \
         "--with-mpfr=$(pack_get --prefix mpfr[3.1.2])"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload build-tools"
