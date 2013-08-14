tmp="$(which flex)"
[ "${tmp:0:1}" == "/" ] && return 0
add_package --build generic http://prdownloads.sourceforge.net/flex/flex-2.5.37.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/flex

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install