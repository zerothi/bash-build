v=1.9.1
add_package \
    --build generic \
    --no-default-modules \
    --package vmd \
    --version $v \
    http://www.ks.uiuc.edu/Research/vmd/vmd-$v/files/final/vmd-$v.bin.LINUXAMD64.opengl.tar.gz

pack_set --module-opt "--lua-family vmd"

# Force the named alias
pack_set --directory vmd-$(pack_get --version)

pack_set --install-query $(pack_get --prefix)/bin/vmd

# Install commands that it should run
pack_set --command "VMDINSTALLBINDIR=$(pack_get --prefix)/bin" \
    --command-flag "VMDINSTALLLIBRARYDIR=$(pack_get --LD)" \
    --command-flag "./configure"

# Make commands
pack_set --command "cd src"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
