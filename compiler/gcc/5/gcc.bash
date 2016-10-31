v=5.4.0
add_package --build generic \
	    http://ftp.download-by.net/gnu/gnu/gcc/gcc-$v/gcc-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list --prefix '--module-requirement ' build-tools \
		mpfr[$mpfr_v] mpc[$mpc_v] isl[$isl_v])

pack_set --install-query $(pack_get --prefix)/bin/gcc

languages="c,c++,fortran,objc,obj-c++"
if ! $(is_host atto) ; then
    languages="$languages,go"
fi

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--with-gmp=$(pack_get --prefix gmp[$gmp_v])" \
	 "--with-mpfr=$(pack_get --prefix mpfr[$mpfr_v])" \
	 "--with-mpc=$(pack_get --prefix mpc[$mpc_v])" \
	 "--with-isl=$(pack_get --prefix isl[$isl_v])" \
	 "--enable-lto --enable-threads" \
	 "--enable-stage1-languages=$languages" \
	 "--with-multilib-list=m64"

# Make commands
pack_cmd "make BOOT_LDFLAGS='$(list --LD-rp gmp[$gmp_v] mpfr[$mpfr_v] mpc[$mpc_v] isl[$isl_v])' $(get_make_parallel)"
# make check requires autogen installed
#pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test

# Add to LD_LIBRARY_PATH, this ensures that at least 
# these libraries always will be present in LD
pack_set --module-opt "--prepend-ENV LD_LIBRARY_PATH=$(pack_get --prefix)/lib64"
