add_package http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw_mpi.a

# FFTW doesn't really need the OpenMPI linking
#pack_set --module-requirement openmpi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--enable-mpi" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

module load $(pack_get --module-name openmpi)
pack_install
module unload $(pack_get --module-name openmpi)
