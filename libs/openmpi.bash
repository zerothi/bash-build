# Install the easiest first... OpenMPI
# old_v  1.6.4

# Newest 1.6.5
add_package http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.4.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpif90

pack_set --host-reject surt --host-reject thul
pack_set --host-reject slid

tmp_flags=""
if $(is_host n-) ; then # enables the linking to the torque management system
    tmp_flags="--with-tm=/opt/torque"
    # For OpenMPI versions above 1.6.2 it uses hwloc for maffinity (hwloc uses libnuma internally)
    # so no need for using libnuma
elif $(is_host surt) ; then
    tmp_flags="CPPFLAGS='-I/usr/include/torque' --with-openib-libdir=/usr/lib64"

elif $(is_host thul) ; then
    tmp_flags="CPPFLAGS='-I/usr/local/include'"

fi

# Install commands that it should run
pack_set --command "../configure $tmp_flags" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

# Required libs:
#  libc6-dev
