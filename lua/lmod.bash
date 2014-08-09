# This requires system packages:
#  libtoolize/libtool
#  automake

v=5.7.2
add_package --build generic-empty \
    --archive lmod-$v.tar.gz \
    --directory Lmod-$v \
    https://github.com/TACC/Lmod/archive/$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix)/lmod/$(pack_get --version)/init/bash

# Configure the package
pack_set --command "unset LUA_PATH && ./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-lua-include=$(pack_get --install-prefix lua)/include"

# Make lua package
pack_set --command "make pre-install"

# Make install lua
pack_set --command "make install"

