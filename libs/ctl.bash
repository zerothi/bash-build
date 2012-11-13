# We will only install this on the super computer
tmp="$(hostname)"
[ "${tmp:0:2}" != "n-" ] && return 0
    
add_package http://ab-initio.mit.edu/libctl/libctl-3.2.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libctl.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install
