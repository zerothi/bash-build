mpc_v=1.1.0
add_package --build generic \
	    --package $gcc-mpc \
	    --alias mpc \
	    ftp://ftp.gnu.org/gnu/mpc/mpc-$mpc_v.tar.gz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libmpc.a

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--with-gmp=$pre" \
         "--with-mpfr=$pre"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > mpc.test 2>&1"
pack_cmd "make install"
pack_set_mv_test mpc.test
