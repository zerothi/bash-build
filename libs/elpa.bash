v=2015.05.001
add_package http://elpa.rzg.mpg.de/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libelpa.a

pack_set --module-requirement mpi

if $(is_c intel) ; then
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"

else
    pack_set --module-requirement scalapack
    tmp="-lscalapack"
    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    [[ "x$la" == "xatlas" ]] && \
		tmp="$tmp -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    break
	fi
    done
fi

# We cannot use OpenMP threading as it requires sequential BLAS
pack_cmd "../configure CC='$MPICC' CXX='$MPICXX' FC='$MPIFC' F90='$MPIF90' SCALAPACK_LDFLAGS='$tmp'" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

