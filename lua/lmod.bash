# This requires system packages:
#  libtoolize/libtool
#  automake

v=7.8.2
add_package --build generic-empty \
    --archive lmod-$v.tar.gz \
    --directory Lmod-$v \
    https://github.com/TACC/Lmod/archive/$v.tar.gz

pack_set --module-requirement luafilesystem

pack_set --install-query $(pack_get --prefix)/lmod/$(pack_get --version)/init/bash

# Configure the package
pack_cmd "unset LUA_PATH && ./configure" \
        "--prefix=$(pack_get --prefix)" \
        "--with-lua-include=$(pack_get --prefix lua)/include"

# Make lua package
pack_cmd "make pre-install"

# Make install lua
pack_cmd "make install"

