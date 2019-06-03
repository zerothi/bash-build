gmp_v=6.1.0
add_package --build generic \
	    --package $gcc-gmp --version $gmp_v --directory gmp-${gmp_v//[a-z]/} \
            https://gmplib.org/download/gmp/gmp-$gmp_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/lib/libgmp.a

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--enable-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > gmp.test 2>&1"
pack_cmd "make install"
pack_store gmp.test
