# Install Python 3.3.0
add_package http://www.python.org/ftp/python/3.3.0/Python-3.3.0.tgz

pack_set --alias python

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# The installation directory
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/python3

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

# Install all relevant python packages
# The lookup name in the list for version number etc...
set_parent python-3
set_parent_exec python3
# Install all python packages
source python-install.bash
clear_parent