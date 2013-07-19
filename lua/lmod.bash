# This requires system packages:
#  libtoolize/libtool
#  automake

add_package http://downloads.sourceforge.net/project/lmod/Lmod-5.1.0.tar.bz2

pack_set -s $IS_MODULE

pack_set --alias lmod
pack_set --prefix-and-module $(pack_get --alias)/$(get_c)
pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix)/lmod

# Configure the package
pack_set --command "./configure" \
	--command-flag "--prefix=$(pack_get --install-prefix)" \
	--command-flag "--with-lua-include=$(pack_get --install-prefix lua)/include"

# Make lua package
pack_set --command "make pre-install"

# Make install lua
pack_set --command "make install"

#pack_set --module-opt --

