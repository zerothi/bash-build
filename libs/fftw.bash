function tmp_func {
    pack_cmd "make $(get_make_parallel)"
    if ! $(is_host n-) ; then
	pack_cmd "make check > fftw.test 2>&1 || echo 'forced'"
	pack_store fftw.test $1
    fi
    pack_cmd "make install"
    pack_cmd "rm -rf ./*"
    shift
}


v=3.3.10
add_package -alias fftw \
            -version $v \
            -package fftw \
	    http://www.fftw.org/fftw-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libfftw3_omp.a

pack_set -lib -lfftw3 -lm
pack_set -lib[omp] -lfftw3_omp -lfftw3 -lm
pack_set -lib[pt] -lfftw3_threads -lfftw3 -lm
pack_set -lib[f] -lfftw3f -lm
pack_set -lib[fomp] -lfftw3f_omp -lfftw3f -lm
pack_set -lib[fpt] -lfftw3f_threads -lfftw3f -lm

pack_cmd "unset CFLAGS"

# Create generic flags for SSE/SIMD extensions
# These flags hosts both MPI and serial FFTW
tmp_flags=
if $(grep "sse2 " /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-sse2"
fi
if $(grep "avx " /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx"
    if $(grep "fma " /proc/cpuinfo > /dev/null) ; then
	tmp_flags="$tmp_flags --enable-avx128-fma"
    fi
fi
if $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx2"
fi
if [[ $(vrs_cmp $(pack_get -version) 3.3.8) -gt 0 ]]; then
    # AVX512 on <= 3.3.8 is extremely slow! So don't use it!
    if $(grep "avx512" /proc/cpuinfo > /dev/null) ; then
	tmp_flags="$tmp_flags --enable-avx512"
    fi
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
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.$ext

    # create the SMP version
    pack_cmd "../configure $flag CFLAGS='$CFLAGS'" \
	     "--enable-threads" \
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.smp.$ext

    # create the OpenMP version
    pack_cmd "LIB='$FLAG_OMP' CFLAGS='$CFLAGS $FLAG_OMP' FFLAGS='$FFLAGS $FLAG_OMP' ../configure $flag" \
	     "--enable-openmp" \
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.omp.$ext

done

#### COMPLETED

# Create mpi fftw
add_package -alias fftw-mpi -package fftw-mpi \
	    $(pack_get -archive)

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libfftw3_threads.a

pack_set -lib -lfftw3_mpi -lfftw3 -lm
pack_set -lib[omp] -lfftw3_mpi -lfftw3_omp -lfftw3 -lm
pack_set -lib[pt] -lfftw3_mpi -lfftw3_threads -lfftw3 -lm
pack_set -lib[f] -lfftw3f_mpi -lfftw3f -lm
pack_set -lib[fomp] -lfftw3f_mpi -lfftw3f_omp -lfftw3f -lm
pack_set -lib[fpt] -lfftw3f_mpi -lfftw3f_threads -lfftw3f -lm

pack_set -mod-req mpi

pack_cmd "unset CFLAGS"

mpi_flags="$(list -LD-rp mpi)"
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
    flag="$flag CC='$MPICC' FC='$MPIF90'"

    pack_cmd "../configure $flag CFLAGS='$mpi_flags $CFLAGS' FFLAGS='$mpi_flags $FFLAGS'" \
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.mpi.$ext

    # create the SMP version
    pack_cmd "../configure $flag CFLAGS='$mpi_flags $CFLAGS' FFLAGS='$mpi_flags $FFLAGS'" \
	     "--enable-threads" \
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.mpi.smp.$ext

    # create the OpenMP version
    pack_cmd "LIB='$FLAG_OMP' ../configure $flag CFLAGS='$mpi_flags $CFLAGS $FLAG_OMP' FFLAGS='$mpi_flags $FFLAGS $FLAG_OMP'" \
	     "--enable-openmp" \
	     "--prefix $(pack_get -prefix)"
    tmp_func fftw.test.mpi.omp.$ext

done

unset tmp_func
