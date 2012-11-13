# Install the easiest first... OpenMPI
add_package http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpif90

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"


pack_install