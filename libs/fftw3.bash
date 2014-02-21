add_package \
    --alias fftw-3 \
    http://www.fftw.org/fftw-3.3.3.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw3_mpi.a

# Install commands that it should run
pack_set --command "module load $(pack_get --module-name-requirement openmpi) $(pack_get --module-name openmpi)"

for flag in --enable-single nothing ; do
    if [ "$flag" == "nothing" ]; then
	flag=""
    fi
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --install-prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"


# create the SMP version
pack_set --command "rm -rf ./*"
pack_set --command "../configure $flag" \
    --command-flag "--enable-mpi" \
    --command-flag "--enable-threads" \
    --command-flag "--prefix $(pack_get --install-prefix)"
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

# create the OpenMP version
pack_set --command "rm -rf ./*"
if test -z "$FLAG_OMP" ; then
    doerr FFTW3 "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

pack_set --command "LIB='$FLAG_OMP' CFLAGS='$CFLAGS $FLAG_OMP' FFLAGS='$FFLAGS $FLAG_OMP' ../configure $flag" \
    --command-flag "--enable-mpi" \
    --command-flag "--enable-openmp" \
    --command-flag "--prefix $(pack_get --install-prefix)"
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

done

pack_set --command "module unload $(pack_get --module-name openmpi) $(pack_get --module-name-requirement openmpi)"
