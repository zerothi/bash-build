# Requires package:
#  apt-get libreadlineX-dev
unset LUA_PATH

add_package --build generic http://www.lua.org/ftp/lua-5.3.2.tar.gz

pack_set -s $IS_MODULE

tmp=
if [[ $(pack_installed readline) -eq 1 ]]; then
    pack_set --mod-req readline
    tmp="$(list -LD-rp readline) $(pack_get --lib readline)"
fi
if [[ $(pack_installed termcap) -eq 1 ]]; then
    pack_set --mod-req termcap
    tmp="$tmp $(list -LD-rp termcap) $(pack_get --lib termcap)"
fi

pack_set --install-query $(pack_get --prefix)/bin/lua

# Correct the installation compilation
pack_cmd "sed -i -e '/^CC/{s:.*:CC = $CC:}' src/Makefile"
pack_cmd "sed -i -e '/^MYLIBS/{s:.*:MYLIBS = $tmp:}' src/Makefile"
# -DLUA_COMPAT_BITLIB and -DLUA_COMPAT_APIINTCASTS are for the bit32 lib
# -DLUA_COMPAT_ALL is not used for 5.3
pack_cmd "sed -i -e '/^CFLAGS/{s:.*:CFLAGS = $CFLAGS -DLUA_COMPAT_BITLIB -DLUA_COMPAT_APIINTCASTS \$(SYSCFLAGS) \$(MYCFLAGS):}' src/Makefile"

# Correct the default package directory
pack_cmd "sed -i -e 's:define LUA_ROOT.*:define LUA_ROOT  \"$(pack_get --prefix)/\":' src/luaconf.h"

pack_cmd "make linux test"

# Make install lua
pack_cmd "make install INSTALL_TOP=$(pack_get --prefix)"

