# apt-get libc6-dev

add_package http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.1.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpif90

pack_set --host-reject surt muspel slid

pack_set --module-requirement hwloc

tmp_flags=""
if $(is_host n-) ; then # enables the linking to the torque management system
    tmp_flags="--with-tm=/opt/torque"
    # For OpenMPI versions above 1.6.2 it uses hwloc for maffinity (hwloc uses libnuma internally)
    # so no need for using libnuma
elif $(is_host surt muspel slid) ; then
    tmp_flags="CPPFLAGS='-I/usr/include/torque' --with-openib-libdir=/usr/lib64"

elif $(is_host thul) ; then
    tmp_flags="CPPFLAGS='-I/usr/local/include'"

fi

if [ $(pack_installed flex) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi


# Install commands that it should run
pack_set --command "../configure $tmp_flags" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-hwloc=$(pack_get --install-prefix hwloc)"

# Fix for the GNU-compiler (it just removes erroneous library linkers)
pack_set --command "sed -i -e '/postdeps/{s:-l ::gi}' libtool"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test


if [ $(pack_installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
