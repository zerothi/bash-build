add_package http://www.povray.org/redirect/www.povray.org/ftp/pub/povray/Official/Linux/povlinux-3.6.tgz

pack_set -s $IS_MODULE

# Force the named alias
pack_set --install-query $(pack_get --install-prefix)/bin/povray

# install commands... (this will install the non-GUI version)
pack_set --command "./install -no-arch-check <<EOF '2
U
$(pack_get --install-prefix)
EOF"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
