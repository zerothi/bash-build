add_package http://www.student.dtu.dk/~nicpa/packages/gdis-0.91b.tar.gz

pack_set -s $IS_MODULE

# Force the named alias
pack_set --install-query $(pack_get --install-prefix)/bin/gdis

# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
# install commands... (this will install the non-GUI version)
pack_set --command "echo '2
$(pack_get --install-prefix)/bin' | ./install"
# Apparently it is not made executable
pack_set --command "chmod a+x $(pack_get --install-prefix)/bin/gdis"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
