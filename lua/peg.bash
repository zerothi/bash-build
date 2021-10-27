add_package --build generic \
    http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.2.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/lpeg.so

# Configure the package
pack_cmd "sed -i -e 's:^LUADIR.*:LUADIR=$(pack_get --prefix lua):' makefile"

pack_cmd "make linux"

pack_cmd "cp lpeg.so $(pack_get --LD lua)/lua/$lua_V/lpeg.so"

