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
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag CFLAGS='$CFLAGS'" \
    --command-flag "--prefix $(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.$ext
fi
pack_set --command "make install"


# create the SMP version
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag CFLAGS='$CFLAGS'" \
    --command-flag "--enable-threads" \
    --command-flag "--prefix $(pack_get --prefix)"
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.smp.$ext
fi
pack_set --command "make install"


# create the OpenMP version
pack_set --command "rm -rf ./*"
if test -z "$FLAG_OMP" ; then
    doerr FFTW3 "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

pack_set --command "LIB='$FLAG_OMP' CFLAGS='$CFLAGS $FLAG_OMP' FFLAGS='$FFLAGS $FLAG_OMP' ../configure $flag" \
    --command-flag "--enable-openmp" \
    --command-flag "--prefix $(pack_get --prefix)"
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.omp.$ext
fi
pack_set --command "make install"

done


# Create mpi fftw-3
add_package \
    --alias fftw-3-mpi \
    $(pack_get --archive)

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR
pack_set --prefix $(pack_get --prefix fftw-3)

pack_set --install-query $(pack_get --LD)/libfftw3_mpi.a

pack_set -mod-req mpi

mpi_flags="$(list --LD-rp mpi)"
for flag in --enable-single nothing ; do
    ext=f
    if [ "$flag" == "nothing" ]; then
	flag=""
	ext=d
    fi
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag CFLAGS='$mpi_flags $CFLAGS'" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.mpi.$ext
fi
pack_set --command "make install"


# create the SMP version
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag CFLAGS='$mpi_flags $CFLAGS'" \
    --command-flag "--enable-mpi" \
    --command-flag "--enable-threads" \
    --command-flag "--prefix $(pack_get --prefix)"
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.smp.mpi.$ext
fi
pack_set --command "make install"


# create the OpenMP version
pack_set --command "rm -rf ./*"
if test -z "$FLAG_OMP" ; then
    doerr FFTW3 "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

pack_set --command "LIB='$FLAG_OMP' CFLAGS='$mpi_flags $CFLAGS $FLAG_OMP' FFLAGS='$mpi_flags $FFLAGS $FLAG_OMP' ../configure $flag" \
    --command-flag "--enable-mpi" \
    --command-flag "--enable-openmp" \
    --command-flag "--prefix $(pack_get --prefix)"
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n-) ; then
    pack_set --command "make check > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.omp.mpi.$ext
fi
pack_set --command "make install"

done
