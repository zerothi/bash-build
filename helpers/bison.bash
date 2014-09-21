add_package --build generic http://ftp.gnu.org/gnu/bison/bison-2.6.5.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

tmp="$(which bison 2>/dev/null)"
[ "${tmp:0:1}" == "/" ] && pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --prefix)/bin/bison

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install