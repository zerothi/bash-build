# Install Python 2.7.3

add_package http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz

pack_set --alias python

# The settings
pack_set -s $BUILD_DIR -s $CONFIGURE -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/python

pack_set --module-name $(pack_get --alias)/$(pack_get --version)/$(get_c)