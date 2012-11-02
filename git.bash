# Now we can install NetCDF (we need the C version to be first added!)
add_package http://git-core.googlecode.com/files/git-1.8.0.tar.gz

pack_set -s $CONFIGURE -s $MAKE_INSTALL -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/git