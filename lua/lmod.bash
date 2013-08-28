# This requires system packages:
#  libtoolize/libtool
#  automake

add_package --build generic-empty \
    --package lmod \
    http://downloads.sourceforge.net/project/lmod/Lmod-5.1.5.tar.bz2

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix)/lmod/$(pack_get --version)/init/bash

# Configure the package
pack_set --command "./configure" \
	--command-flag "--prefix=$(pack_get --install-prefix)" \
	--command-flag "--with-lua-include=$(pack_get --install-prefix lua)/include"

# Make lua package
pack_set --command "make pre-install"

# Make install lua
pack_set --command "make install"

