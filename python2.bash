# Install Python 2.7.3
add_package http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz

pack_set --alias python
pack_set --index-alias python-2

# The settings
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# The installation directory
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/python

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name) 


# Install all relevant python packages
# Load the python just installed

# The lookup name in the list for version number etc...
set_parent python-2
set_parent_exec python
# Install all python packages
source python-install.bash
clear_parent