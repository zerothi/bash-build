add_package --build generic http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.4.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix build-tools)/lib/libunistring.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
