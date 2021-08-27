v=5.2.0
add_package --package flame --archive libflame-$v.tar.gz \
	    https://github.com/flame/libflame/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --LD)/libflame.a

# Clean makefile
pack_cmd "sed -ie '/define EOL/{N;N;N;d}' Makefile"

# To print-out compile lines add this to the Makefile command
#   FLA_ENABLE_VERBOSE_MAKE_OUTPUT=yes

# First install openmp
pack_cmd "./configure" \
	 "--enable-static-build" \
	 "--enable-lapack2flame" \
	 "--enable-autodetect-f77-ldflags" \
	 "--enable-autodetect-f77-name-mangling" \
	 "--enable-multithreading=openmp" \
	 --enable-vector-intrinsics=sse \
	 "--enable-supermatrix" \
	 "--disable-profiling" \
	 "--enable-blis-use-of-fla-malloc" \
	 "--prefix=$(pack_get --prefix)"
pack_store config.log config.log.omp
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "pushd $(pack_get --LD)"
pack_cmd "rm -f libflame.a libflame.so"
pack_cmd "for d in *.a ; do mv \$d \${d//.a/_omp.a} ; done"
#pack_cmd "for d in *.so ; do mv \$d \${d//.so/_omp.so} ; done"
pack_cmd "ln -s libflame*.a libflame_omp.a"
#pack_cmd "ln -s libflame*.so libflame_omp.so"
pack_cmd "popd"

# First install pthreads
pack_cmd "make clean"
pack_cmd "./configure" \
	 "--enable-static-build" \
	 "--enable-lapack2flame" \
	 "--enable-autodetect-f77-ldflags" \
	 "--enable-autodetect-f77-name-mangling" \
	 "--enable-multithreading=pthreads" \
	 --enable-vector-intrinsics=sse \
	 "--enable-supermatrix" \
	 "--disable-profiling" \
	 "--enable-blis-use-of-fla-malloc" \
	 "--prefix=$(pack_get --prefix)"
pack_store config.log config.log.pthreads
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "pushd $(pack_get --LD)"
pack_cmd "rm -f libflame.a libflame.so"
pack_cmd "for d in *[^p].a ; do mv \$d \${d//.a/_pt.a} ; done"
#pack_cmd "for d in *[^p].so ; do mv \$d \${d//.so/_pt.so} ; done"
pack_cmd "ln -s libflame*[^p].a libflame_pt.a"
#pack_cmd "ln -s libflame*[^p].so libflame_pt.so"
pack_cmd "popd"

pack_cmd "make clean"
pack_cmd "./configure" \
	 "--enable-static-build" \
	 "--enable-lapack2flame" \
	 "--enable-autodetect-f77-ldflags" \
	 "--enable-autodetect-f77-name-mangling" \
	 --enable-vector-intrinsics=sse \
	 "--enable-supermatrix" \
	 "--disable-profiling" \
	 "--enable-blis-use-of-fla-malloc" \
	 "--prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
