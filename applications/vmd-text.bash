v=1.9.1
add_package \
    --package vmd-text \
    --version $v \
    http://www.ks.uiuc.edu/Research/vmd/vmd-1.9.1/files/final/vmd-$v.bin.LINUXPPC64.text.tar.gz

pack_set -s $IS_MODULE

# Force the named alias
pack_set --directory vmd-$(pack_get --version)

pack_set --install-query $(pack_get --install-prefix)/bin/vmd

# Install commands that it should run
pack_set --command "VMDINSTALLBINDIR=$(pack_get --install-prefix)/bin" \
    --command-flag "VMDINSTALLLIBRARYDIR=$(pack_get --install-prefix)/lib" \
    --command-flag "./configure"

# Make commands
pack_set --command "cd src"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(build_get --default-module) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
