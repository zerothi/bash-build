# Install the easiest first... OpenMPI
add_package http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpif90

tmp=$(hostname)
tmp_flags=""
if [ "${tmp:0:2}" == "n-" ]; then # enables the linking to the torque management system
    tmp_flags="--with-tm=/opt/torque"
    # For OpenMPI versions above 1.6.2 it uses hwloc for maffinity (hwloc uses libnuma internally)
    # so no need for using libnuma
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix) $tmp_flags"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"


pack_install