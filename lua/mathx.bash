add_package --build generic \
    --directory mathx \
    --version 5.3 \
    http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.3/lmathx.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/mathx.so

# Configure the package
file=Makefile
pack_cmd "sed -i -e '/^LUA/{d}' $file"
pack_cmd "sed -i -e 's:^CFLAGS[ ]*=:CFLAGS = $CFLAGS:gi' $file"
pack_cmd "sed -i -e '$ aLUA=$(pack_get --prefix lua)\n\
LUAINC=\$(LUA)/include\n\
LUALIB=\$(LUA)/lib\n\
LUABIN=\$(LUA)/bin' $file"

pack_cmd "make all"

pack_cmd "cp mathx.so $(pack_get --LD lua)/lua/$lua_V/mathx.so"

