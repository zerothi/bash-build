cloog_v=0.18.1
add_package --build generic --package $gcc-cloog \
	    ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$cloog_v.tar.gz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement gcc-prereq[$gcc_v]

pre=$(pack_get --prefix gcc-prereq[$gcc_v])
pack_set --prefix $pre
pack_set --install-query $pre/bin/cloog

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
         "--with-isl=system" \
         "--with-isl-prefix=$pre" \
         "--with-gmp=system" \
         "--with-gmp-prefix=$pre"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > cloog.test 2>&1"
pack_cmd "make install"
pack_set_mv_test cloog.test

pack_cmd "module unload build-tools"
