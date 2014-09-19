v=3.1
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --install-prefix)/bin/mpiexec

# Only install locally
pack_set $(list -p "--host-reject " surt muspel slid n- hemera eris $(get_hostname))

# Install commands that it should run
pack_set --command "unset F90 && unset F90FLAGS && ../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-f77 --enable-fc --enable-cxx" \
    --command-flag "--enable-shared --enable-smpcoll $tmp_flags"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
