mpfr_v=4.0.2
add_package --build generic \
	    http://www.mpfr.org/mpfr-$mpfr_v/mpfr-$mpfr_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $IS_MODULE -s $BUILD_TOOLS

pack_set --module-requirement gmp[$gmp_v]

pack_set --install-query $(pack_get --prefix)/lib/libmpfr.a

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--with-gmp=$(pack_get --prefix gmp[$gmp_v])"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > mpfr.test 2>&1"
pack_cmd "make install"
pack_store mpfr.test
