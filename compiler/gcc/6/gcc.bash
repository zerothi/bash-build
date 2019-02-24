add_package --build generic \
	    http://ftp.download-by.net/gnu/gnu/gcc/gcc-$gcc_v/gcc-$gcc_v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list --prefix '--module-requirement ' build-tools gcc-prereq[$gcc_v])

pack_set --library-suffix "lib lib64"

pre=$(pack_get --prefix)
pack_set --install-query $pre/bin/gcc


languages="c,c++,lto,fortran,objc,obj-c++,java"
if ! $(is_host atto) ; then
    languages="$languages,go"
fi

# Install commands that it should run
pack_cmd "../configure --prefix $pre" \
	 "--with-gmp=$pre" \
	 "--with-mpfr=$pre" \
	 "--with-mpc=$pre" \
	 "--with-isl=$pre" \
	 "--with-quad" \
	 "--enable-lto --enable-threads" \
	 "--enable-stage1-languages=$languages" \
	 "--with-multilib-list=m64"
unset languages

# Make commands
pack_cmd "make BOOT_LDFLAGS='$(list --LD-rp gcc-prereq[$gcc_v])' $(get_make_parallel)"
# make check requires autogen installed
pack_cmd "make -k check > gcc.test 2>&1 ; echo 'Succes'"
pack_cmd "make install"
pack_set_mv_test gcc.test
pack_cmd 'for f in **/testsuite/*.log **/testsuite/*.sum ; do mv $f $pre/gcc.$(basename $f) ; gzip -f $pre/gcc.$(basename $f) ; done'

# Add to LD_LIBRARY_PATH, this ensures that at least 
# these libraries always will be present in LD
pack_set --module-opt "--prepend-ENV LD_LIBRARY_PATH=$pre/lib"
pack_set --module-opt "--prepend-ENV LD_LIBRARY_PATH=$pre/lib64"
