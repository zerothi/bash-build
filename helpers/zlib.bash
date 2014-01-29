# First install zlib, which is a simple library
add_package --build generic --alias gen-zlib \
    http://zlib.net/zlib-1.2.8.tar.gz 

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libz.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--static"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

pack_install