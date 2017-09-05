v=2017.05.002
add_package --build debug --package elpa-debug \
	    http://elpa.mpcdf.mpg.de/html/Releases/$v/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libelpa.a

pack_set --module-requirement mpi

if $(is_c intel) ; then
    # Here we need static blacs
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    if $(is_host slid muspel thul surt) ; then
        tmp="$tmp -L/usr/lib64"
    fi

else
    
    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib $la)"
    
fi

# We cannot use OpenMP threading as it requires sequential BLAS
pack_cmd "../configure CPP='$MPICC -E -P -x c' CC='$MPICC' CFLAGS='$CFLAGS' FC='$MPIFC' FCFLAGS='$FCFLAGS' SCALAPACK_LDFLAGS='$tmp'" \
	 "--prefix=$(pack_get --prefix)" \
	 "$(list --prefix ' --disable-' sse sse-assembly avx avx2)"

# This will fail, we have to circumvent it
pack_cmd "make $(get_make_parallel) ; echo force"
# Fix
pack_cmd "sed -i 's/_COMPILED@) \\\\//g;s/@//g' elpa/elpa_constants.h"
pack_cmd "make clean"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

