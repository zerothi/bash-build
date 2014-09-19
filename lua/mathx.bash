add_package --build generic \
    --version 5.2 \
    --directory mathx \
    http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.2/lmathx.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --library-path lua)/lua/$lua_V/mathx.so

# Configure the package
file=Makefile
pack_set --command "sed -i -e '/^LUA/{d}' $file"
pack_set --command "sed -i -e 's:^CFLAGS[ ]*=:CFLAGS = $CFLAGS:gi' $file"
pack_set --command "sed -i -e '$ aLUA=$(pack_get --install-prefix lua)\n\
LUAINC=\$(LUA)/include\n\
LUALIB=\$(LUA)/lib\n\
LUABIN=\$(LUA)/bin' $file"

pack_set --command "make all"

pack_set --command "cp mathx.so $(pack_get --library-path lua)/lua/$lua_V/mathx.so"

