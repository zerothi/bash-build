# Requires package:
#  libreadlineX-dev
unset LUA_PATH

add_package --build generic http://www.lua.org/ftp/lua-5.3.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/lua

# Correct the installation compilation
pack_set --command "sed -i -e '/^CC/{s:.*:CC = $CC:}' src/Makefile"
# -DLUA_COMPAT_BITLIB and -DLUA_COMPAT_APIINTCASTS are for the bit32 lib
# -DLUA_COMPAT_ALL is not used for 5.3
pack_set --command "sed -i -e '/^CFLAGS/{s:.*:CFLAGS = $CFLAGS -DLUA_COMPAT_BITLIB -DLUA_COMPAT_APIINTCASTS \$(SYSCFLAGS) \$(MYCFLAGS):}' src/Makefile"

# Correct the default package directory
pack_set --command "sed -i -e 's:define LUA_ROOT.*:define LUA_ROOT  \"$(pack_get --prefix)/\":' src/luaconf.h"

# Make lua
if $(is_host hemera eris ponto) ; then
    pack_set --command "make MYLIBS='-lncurses' linux test"
else
    pack_set --command "make linux test"
fi

# Make install lua
pack_set --command "make install INSTALL_TOP=$(pack_get --prefix)"

pack_install
lua_V=5.3

# Source all the lua-packages that will be installed
source_pack lua/rocks.bash
source_pack lua/filesystem.bash
source_pack lua/posix.bash
source_pack lua/mathx.bash
source_pack lua/strip.bash
source_pack lua/complex.bash
source_pack lua/penlight.bash
source_pack lua/peg.bash
source_pack lua/lmod.bash

