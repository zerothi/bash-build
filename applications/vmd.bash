v=1.9.2
add_package --build generic \
    --no-default-modules \
    --package vmd \
    --version $v \
    http://www.ks.uiuc.edu/Research/vmd/vmd-$v/files/final/vmd-$v.bin.LINUXAMD64.opengl.tar.gz

pack_set -s $IS_MODULE -s $CRT_DEF_MODULE

pack_set --module-opt "--lua-family vmd"

# Force the named alias
pack_set --directory vmd-$(pack_get --version)

pack_set --install-query $(pack_get --prefix)/bin/vmd

# Install commands that it should run
pack_cmd "VMDINSTALLBINDIR=$(pack_get --prefix)/bin" \
    "VMDINSTALLLIBRARYDIR=$(pack_get --LD)" \
    "./configure"

# Make commands
pack_cmd "cd src"
pack_cmd "make install"
