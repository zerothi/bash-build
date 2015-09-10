add_package --build generic \
	    ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-5.2.0/gcc-5.2.0.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list --prefix '--module-requirement ' build-tools \
		gmp[6.0.0a] mpfr[3.1.3] mpc[1.0.3] isl[0.15])

pack_set --install-query $(pack_get --prefix)/bin/gcc

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--with-gmp=$(pack_get --prefix gmp[6.0.0a])" \
	 "--with-mpfr=$(pack_get --prefix mpfr[3.1.3])" \
	 "--with-mpc=$(pack_get --prefix mpc[1.0.3])" \
	 "--with-isl=$(pack_get --prefix isl[0.15])" \
	 "--enable-lto --enable-threads" \
	 "--enable-stage1-languages=c,c++,fortran,go,objc,obj-c++" \
	 "--with-multilib-list=m64"

# Make commands
pack_cmd "make BOOT_LDFLAGS='$(list --LD-rp gmp[6.0.0a] mpfr[3.1.3] mpc[1.0.3] isl[0.15])' $(get_make_parallel)"
# make check requires autogen installed
#pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test

# Add to LD_LIBRARY_PATH, this ensures that at least 
# these libraries always will be present in LD
pack_set --module-opt "--prepend-ENV LD_LIBRARY_PATH=$(pack_get --prefix)/lib64"
