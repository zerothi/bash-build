add_package \
    --alias fftw-2 \
    http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw_mpi.a

# Install commands that it should run
pack_set --command "module load $(build_get --default-module)"
pack_set --command "module load $(pack_get --module-name openmpi)"

pack_set --command "../configure" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

pack_set --command "module unload $(pack_get --module-name openmpi) $(build_get --default-module)"

