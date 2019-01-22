add_package --build generic \
    --directory mathx \
    --version 5.3 \
    http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/5.3/lmathx.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/mathx.so

pack_cmd "make LUA=$(pack_get --prefix lua) CFLAGS='$CFLAGS' so"
pack_cmd "cp mathx.so $(pack_get --LD lua)/lua/$lua_V/mathx.so"
