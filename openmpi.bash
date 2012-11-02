# Install the easiest first... OpenMPI
add_package http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.2.tar.gz

pack_set -s $BUILD_DIR -s $CONFIGURE -s $MAKE_TEST -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

# The prefix for installation
pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

# What to check for when checking for installation...
pack_set --install-query \
    $(pack_get --install-prefix)/bin/mpif90

