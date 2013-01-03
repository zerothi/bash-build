add_package http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --alias fftw-2
pack_set --install-query $(pack_get --install-prefix)/lib/libfftw_mpi.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

#TODO
module load $(get_default_modules)
module load $(pack_get --module-name openmpi)
module unload $(pack_get --module-name openmpi)
module unload $(get_default_modules)