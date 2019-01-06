isl_v=0.16.1
add_package --build generic \
	    --package $gcc-isl \
	    ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$isl_v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libisl.a

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--with-gmp-prefix=$pre"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > isl.test 2>&1"
pack_cmd "make install"
pack_set_mv_test isl.test
