return 0
v=2015.05.001
add_package http://elpa.rzg.mpg.de/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --module-requirement mpi

if $(is_c intel) ; then
    tmp="-dir=$MKL_PATH/lib/intel64"

else
    pack_set --module-requirement scalapack
    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    [[ "x$la" == "xatlas" ]] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    tmp="--with-lapack-lib='-llapack' --with-blas-lib='$tmp'"
	    break
	fi
    done
    tmp="$tmp --with-scalapack-dir=$(pack_get --prefix scalapack)"
fi


pack_set --install-query $(pack_get --LD)/libelpa.a

pack_cmd "../configure" \
	 "CC='$MPICC' CFLAGS='$CFLAGS'" \
	 "CXX='$MPICXX' CXXFLAGS='$CFLAGS'" \
	 "FC='$MPIF90' FCFLAGS='$FCFLAGS'" \
	 "F77='$MPIF77' FFLAGS='$FFLAGS'" \
	 "F90='$MPIF90'" \
	 "--enable-shared" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

