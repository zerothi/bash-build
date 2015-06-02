add_package \
    --alias fftw-2 \
    http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libfftw_mpi.a

# Install commands that it should run
pack_set --command "module load $(list -uniq -mod-names +fftw-2 ++mpi)"

pack_set --command "../configure" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

pack_set_mv_test tmp.test

pack_set --command "module unload $(list -uniq -mod-names +fftw-2 ++mpi)"

