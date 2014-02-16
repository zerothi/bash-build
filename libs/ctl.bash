# We will only install this on the super computer
add_package http://ab-initio.mit.edu/libctl/libctl-3.2.1.tar.gz

pack_set --host-reject ntch --host-reject zeroth \
    $(list --prefix "--host-reject " surt muspel slid a0 b0 c0 d0 n0 p0 q0 g0)

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libctl.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

