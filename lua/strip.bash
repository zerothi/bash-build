# This file requires the lua-src to be present
return
add_package --build generic \
    --version 5.3 \
    http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/5.3/lstrip.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/strip.so

# Configure the package
file=Makefile
pack_cmd "sed -i -e '/^LUA/{d}' $file"
pack_cmd "sed -i -e 's:^CFLAGS[ ]*=:CFLAGS = $CFLAGS:gi' $file"
pack_cmd "sed -i -e '$ aLUA=$(pack_get --prefix lua)\n\
LUAINC=\$(LUA)/include\n\
LUALIB=\$(LUA)/lib\n\
LUABIN=\$(LUA)/bin' $file"

pack_cmd "make all"

pack_cmd "cp strip.so $(pack_get --LD lua)/lua/$lua_V/strip.so"

