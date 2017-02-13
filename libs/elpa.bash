v=2016.05.004
add_package http://elpa.mpcdf.mpg.de/html/Releases/$v/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libelpa.a

pack_set --module-requirement mpi

if $(is_c intel) ; then
    # Here we need static blacs
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    if $(is_host slid muspel surt) ; then
        tmp="$tmp -L/usr/lib64"
    fi

else
    
    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="-lscalapack $(pack_get -lib $la)"
    
fi

# We cannot use OpenMP threading as it requires sequential BLAS
pack_cmd "../configure CC='$MPICC' CXX='$MPICXX' FC='$MPIFC' F90='$MPIF90' SCALAPACK_LDFLAGS='$tmp'" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
if $(is_c intel) ; then
    pack_cmd "make install"
else
    pack_cmd "make check > tmp.test 2>&1 ; echo force"
    pack_cmd "make install"
    pack_set_mv_test tmp.test
fi

