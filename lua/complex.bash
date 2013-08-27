add_package --build generic \
    --directory complex \
    --version 5.2 \
    http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.2/lcomplex.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/complex.so

# Configure the package
pack_set --command "sed -i -e '/^LUA/{d}' Makefile"
pack_set --command "sed -i -e '$ aLUA=$(pack_get --install-prefix lua)\n\
LUAINC=\$(LUA)/include\n\
LUALIB=\$(LUA)/lib\n\
LUABIN=\$(LUA)/bin' Makefile"

pack_set --command "make all"

pack_set --command "cp complex.so $(pack_get --install-prefix lua)/lib/lua/$lua_V/complex.so"