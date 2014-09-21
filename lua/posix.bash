# This requires system packages:
#  libtoolize/libtool
#  automake

v=32
add_package --build generic \
    --archive lua-posix-5.1.$v.tar.gz \
    --version 5.1.$v \
    --directory luaposix-release-v$v \
    https://github.com/luaposix/luaposix/archive/release-v$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --library-path lua)/lua/$lua_V/posix_c.so

[ $(pack_installed help2man) -eq 1 ] && \
    pack_set --module-requirement help2man
[ $(pack_installed autoconf) -eq 1 ] && \
    pack_set --module-requirement autoconf

# Configure the package
pack_set --command "./configure" \
	--command-flag "LUA=$(pack_get --prefix lua)/bin/lua" \
	--command-flag "LUA_INCLUDE='-I$(pack_get --prefix lua)/include'" \
	--command-flag "--prefix=$(pack_get --prefix lua)" \
	--command-flag "--libdir=$(pack_get --library-path lua)/lua/$lua_V/" \
	--command-flag "--datarootdir=$(pack_get --prefix lua)/share/lua/$lua_V/" 

# Make lua package
pack_set --command "make all"
pack_set --command "make check"
pack_set --command "make install"

