# apt-get libc6-dev
v=3.1
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpiexec

pack_set --host-reject surt muspel slid

tmp_flags=""
if $(is_host n-) ; then # enables the linking to the torque management system
    tmp_flags=
elif $(is_host surt muspel slid) ; then
    tmp_flags=

fi

# Install commands that it should run
pack_set --command "unset F90 && unset F90FLAGS && ../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-f77 --enable-fc --enable-cxx" \
    --command-flag "--enable-shared --enable-smpcoll $tmp_flags"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

