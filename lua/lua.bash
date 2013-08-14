add_package --build generic http://www.lua.org/ftp/lua-5.2.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/lua

# Correct the installation compilation
pack_set --command "sed -i -e '/^CC/{s/.*/CC = $CC/}' src/Makefile"
pack_set --command "sed -i -e '/^CFLAGS/{s/.*/CFLAGS = $CFLAGS -DLUA_COMPAT_ALL \$(SYSCFLAGS) \$(MYCFLAGS)/}' src/Makefile"

# Correct the default package directory
pack_set --command "sed -i -e 's:define LUA_ROOT.*:define LUA_ROOT  \"$(pack_get --install-prefix)/\":' src/luaconf.h"

# Make lua
pack_set --command "make linux"

# Make install lua
pack_set --command "make install INSTALL_TOP=$(pack_get --install-prefix)"

lua_V=5.2

# Source all the lua-packages that will be installed
source lua/filesystem.bash
source lua/posix.bash
source lua/lmod.bash

install_all --from lua

