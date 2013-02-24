add_package http://www.fftw.org/fftw-3.3.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --alias fftw-3
pack_set --install-query $(pack_get --install-prefix)/lib/libfftw3_mpi.a

pack_set --command "module load $(get_default_modules)"
pack_set --command "module load $(pack_get --module-name openmpi)"
# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_set --command "module unload $(pack_get --module-name openmpi) $(get_default_modules)"
