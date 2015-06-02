function tmp_func {
    pack_set --command "make $(get_make_parallel)"
    if ! $(is_host n-) ; then
	pack_set --command "make check > tmp.test 2>&1"
	pack_set_mv_test tmp.test $1
    fi
    pack_set --command "make install"
    pack_set --command "rm -rf ./*"
    shift
}


add_package \
    --alias fftw-3 \
    http://www.fftw.org/fftw-3.3.4.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libfftw3_omp.a

for flag in --enable-single nothing ; do
    ext=f
    if [ "$flag" == "nothing" ]; then
	flag=""
	ext=d
    fi
pack_set --command "../configure $flag CFLAGS='$CFLAGS'" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.$ext

# create the SMP version
pack_set --command "../configure $flag CFLAGS='$CFLAGS'" \
    --command-flag "--enable-threads" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.smp.$ext

# create the OpenMP version
pack_set --command "LIB='$FLAG_OMP' CFLAGS='$CFLAGS $FLAG_OMP' FFLAGS='$FFLAGS $FLAG_OMP' ../configure $flag" \
    --command-flag "--enable-openmp" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.omp.$ext

done

#### COMPLETED

# Create mpi fftw-3
add_package \
    --package fftw-mpi-3 \
    $(pack_get --archive)

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libfftw3_mpi.a

pack_set -mod-req mpi

mpi_flags="$(list --LD-rp mpi)"
for flag in --enable-single nothing ; do
    ext=f
    if [ "$flag" == "nothing" ]; then
	flag=""
	ext=d
    fi
    flag="$flag CC='$MPICC' CFLAGS='$mpi_flags $CFLAGS'"
    flag="$flag FC='$MPIF90' FFLAGS='$mpi_flags $FCFLAGS'"
    flag="$flag --enable-mpi"

pack_set --command "../configure $flag" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.mpi.$ext

# create the SMP version
pack_set --command "../configure $flag" \
    --command-flag "--enable-threads" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.mpi.smp.$ext

# create the OpenMP version
flag="${flag//FLAGS='/FLAGS='$FLAG_OMP}"
pack_set --command "LIB='$FLAG_OMP' ../configure $flag" \
    --command-flag "--enable-openmp" \
    --command-flag "--prefix $(pack_get --prefix)"
tmp_func tmp.test.mpi.omp.$ext

done
