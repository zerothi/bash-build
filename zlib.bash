# First install zlib, which is a simple library
add_package http://zlib.net/zlib-1.2.7.tar.gz 

pack_set -s $CONFIGURE -s $MAKE_CHECK -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libz.a

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--static"

# Make commands
pack_set --command "make"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"
