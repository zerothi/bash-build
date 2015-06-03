v=1.9.2
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
