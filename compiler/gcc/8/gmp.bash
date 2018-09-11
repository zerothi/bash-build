gmp_v=6.1.2
add_package --build generic \
	    --directory gmp-${gmp_v//[a-z]/} \
	    --version $gmp_v \
	    --package $gcc-gmp \
	    --alias gmp \
            https://gmplib.org/download/gmp/gmp-$gmp_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libgmp.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--enable-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > gmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test gmp.test

pack_cmd "module unload build-tools"
