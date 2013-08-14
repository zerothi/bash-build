# This requires system packages:
#  libtoolize/libtool
#  automake

add_package --build generic \
    --archive lua-posix-5.1.29.tar.gz \
    --version 5.1.29 \
    --directory luaposix-release-v29 \
    https://github.com/luaposix/luaposix/archive/release-v29.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/posix_c.so

[ $(pack_get --installed help2man) -eq 1 ] && \
    pack_set --module-requirement help2man
[ $(pack_get --installed autoconf) -eq 1 ] && \
    pack_set --module-requirement autoconf

# Configure the package
pack_set --command "./configure" \
	--command-flag "LUA=$(pack_get --install-prefix lua)/bin/lua" \
	--command-flag "LUA_INCLUDE='-I$(pack_get --install-prefix lua)/include'" \
	--command-flag "--prefix=$(pack_get --install-prefix lua)" \
	--command-flag "--libdir=$(pack_get --install-prefix lua)/lib/lua/$lua_V/" \
	--command-flag "--datarootdir=$(pack_get --install-prefix lua)/share/lua/$lua_V/" 

# Make lua package
pack_set --command "make all"

# Make the compilation check
pack_set --command "make check"

# Make install lua
pack_set --command "make install"

