isl_v=0.18
add_package --build generic \
	    --package $gcc-isl \
	    --alias isl \
	    http://isl.gforge.inria.fr/isl-$isl_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libisl.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--with-gmp-prefix=$pre"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > isl.test 2>&1"
pack_cmd "make install"
pack_set_mv_test isl.test

pack_cmd "module unload build-tools"
