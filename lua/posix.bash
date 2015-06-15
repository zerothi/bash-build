# This requires system packages:
#  libtoolize/libtool
#  automake
#  libncurses5/libncurses5-dev (or just a curses header)

v=33.3.1
add_package --build generic --package luaposix \
    --archive luaposix-release-v$v.tar.gz \
    https://github.com/luaposix/luaposix/archive/release-v$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/posix.so

[ $(pack_installed build-tools) -eq 1 ] && \
    pack_set --module-requirement build-tools

# Configure the package
pack_set --command "./configure" \
	--command-flag "LUA=$(pack_get --prefix lua)/bin/lua" \
	--command-flag "LUA_INCLUDE='-I$(pack_get --prefix lua)/include'" \
	--command-flag "--prefix=$(pack_get --prefix lua)" \
	--command-flag "--libdir=$(pack_get --LD lua)/lua/$lua_V/" \
	--command-flag "--datarootdir=$(pack_get --prefix lua)/share/lua/$lua_V/" 

# Make lua package
pack_set --command "make all"
pack_set --command "make check"
pack_set --command "make install"

