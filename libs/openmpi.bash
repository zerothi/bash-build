# apt-get libc6-dev
add_package http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.6.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/mpif90

pack_set --module-requirement hwloc

tmp_flags=""
[ -d /opt/torque ] && tmp_flags="$tmp_flags --with-tm=/opt/torque"
[ -e /usr/local/include/tm.h ] && tmp_flags="$tmp_flags --with-tm=/usr/local"
[ -d /usr/include/infiniband ] && tmp_flags="$tmp_flags --with-verbs"

if [ $(pack_installed flex) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Install commands that it should run
pack_set --command "../configure $tmp_flags" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--with-hwloc=$(pack_get --prefix hwloc)" \
    --command-flag "--enable-mpi-cxx"

# Fix for the GNU-compiler (it just removes erroneous library linkers)
pack_set --command "sed -i -e '/postdeps/{s:-l ::gi}' libtool"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set_mv_test tmp.test
pack_set --command "make install"

if [ $(pack_installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
