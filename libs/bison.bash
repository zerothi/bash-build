tmp="$(which bison)"
[ "${tmp:0:1}" == "/" ] && return 0
add_package http://ftp.gnu.org/gnu/bison/bison-2.6.5.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/bison

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

tmp="$(which bison)"
[ "${tmp:0:1}" != "/" ] && \
