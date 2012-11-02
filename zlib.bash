# First install zlib, which is a simple library
add_package http://zlib.net/zlib-1.2.7.tar.gz 

pack_set -s $CONFIGURE -s $MAKE_CHECK -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libz.a
