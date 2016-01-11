# This requires system packages:
#  libtoolize/libtool
#  automake
#  libncurses5/libncurses5-dev (or just a curses header)

v=33.3.1
add_package --build generic --package luaposix \
    --archive luaposix-release-v$v.tar.gz \
    https://github.com/luaposix/luaposix/archive/release-v$v.tar.gz

tmp=$(pack_get --package)

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/posix.so

[ $(pack_installed build-tools) -eq 1 ] && \
    pack_set --module-requirement build-tools

# Configure the package
pack_cmd "./configure" \
	    "LUA=$(pack_get --prefix lua)/bin/lua" \
	    "LUA_INCLUDE='-I$(pack_get --prefix lua)/include'" \
	    "--prefix=$(pack_get --prefix lua)" \
	    "--libdir=$(pack_get --LD lua)/lua/$lua_V/" \
	    "--datarootdir=$(pack_get --prefix lua)/share/lua/$lua_V/$tmp" \
	    "--datadir=$(pack_get --prefix lua)/share/lua/$lua_V/$tmp/lua"

# Make lua package
pack_cmd "make all"
pack_cmd "make check"
pack_cmd "make install"

