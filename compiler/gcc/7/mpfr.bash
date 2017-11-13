mpfr_v=3.1.5
add_package --build generic \
	    --package $gcc-mpfr \
	    --alias mpfr \
	    http://www.mpfr.org/mpfr-$mpfr_v/mpfr-$mpfr_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libmpfr.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--with-gmp=$pre"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > mpfr.test 2>&1"
pack_cmd "make install"
pack_set_mv_test mpfr.test

pack_cmd "module unload build-tools"
