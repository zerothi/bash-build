function tmp_func {
    pack_cmd "make $(get_make_parallel)"
    if ! $(is_host n-) ; then
	pack_cmd "make check > tmp.test 2>&1"
	pack_set_mv_test tmp.test $1
    fi
    pack_cmd "make install"
    pack_cmd "rm -rf ./*"
    shift
}


add_package --alias fftw-3 \
	    http://www.fftw.org/fftw-3.3.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libfftw3_omp.a
pack_set --lib -lfftw3
pack_set --lib[omp] -lfftw3_omp
pack_set --lib[pt] -lfftw3_threads

pack_cmd "unset CFLAGS"

# Create generic flags for SSE/SIMD extensions
tmp_flags=
if $(grep "sse2 " /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-sse2"
fi
if $(grep "avx " /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx"
fi
if $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx2"
fi

for flag in --enable-single nothing ; do
    ext=f
    if [[ "$flag" == "nothing" ]]; then
	flag=""
	ext=d
    else
	if $(grep "sse " /proc/cpuinfo > /dev/null) ; then
	    # Only allow SSE for float
	    flag="$flag --enable-sse"
	fi
    fi
    # Add default flags
    flag="$flag $tmp_flags"
    
    pack_cmd "../configure $flag CFLAGS='$CFLAGS'" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.$ext

    # create the SMP version
    pack_cmd "../configure $flag CFLAGS='$CFLAGS'" \
	     "--enable-threads" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.smp.$ext

    # create the OpenMP version
    pack_cmd "LIB='$FLAG_OMP' CFLAGS='$CFLAGS $FLAG_OMP' FFLAGS='$FFLAGS $FLAG_OMP' ../configure $flag" \
	     "--enable-openmp" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.omp.$ext

done

#### COMPLETED

# Create mpi fftw-3
add_package --alias fftw-mpi-3 --package fftw-mpi \
	    $(pack_get --archive)

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libfftw3_mpi.a

pack_set -mod-req mpi

pack_cmd "unset CFLAGS"

mpi_flags="$(list --LD-rp mpi)"
for flag in --enable-single nothing ; do
    ext=f
    if [[ "$flag" == "nothing" ]]; then
	flag=""
	ext=d
    else
	if $(grep "sse " /proc/cpuinfo > /dev/null) ; then
	    # Only allow SSE for float
	    flag="$flag --enable-sse"
	fi
    fi
    flag="$flag --enable-mpi $tmp_flags"
    flag="$flag CC='$MPICC' \
CFLAGS='$mpi_flags $CFLAGS' FC='$MPIF90' FFLAGS='$mpi_flags $FFLAGS'"

    pack_cmd "../configure $flag" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.mpi.$ext

    # create the SMP version
    pack_cmd "../configure $flag" \
	     "--enable-threads" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.mpi.smp.$ext

    # create the OpenMP version
    flag="${flag//FLAGS='/FLAGS='$FLAG_OMP}"
    pack_cmd "LIB='$FLAG_OMP' ../configure $flag" \
	     "--enable-openmp" \
	     "--prefix $(pack_get --prefix)"
    tmp_func tmp.test.mpi.omp.$ext

done

unset tmp_func
