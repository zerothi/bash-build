add_package --build generic \
    http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-0.12.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/lpeg.so

# Configure the package
pack_set --command "sed -i -e 's:^LUADIR.*:LUADIR=$(pack_get --install-prefix lua):' makefile"

pack_set --command "make linux"

pack_set --command "cp lpeg.so $(pack_get --install-prefix lua)/lib/lua/$lua_V/lpeg.so"

