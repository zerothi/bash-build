# This requires system packages:
#  libtoolize/libtool
#  automake

add_package \
    --archive lua-posix.zip \
    --directory luaposix-master \
    https://github.com/luaposix/luaposix/archive/master.zip

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/posix_c.so

# bootstrap
pack_set --command "./bootstrap"

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

