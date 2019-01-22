add_package --build generic \
    --version 5.3 \
    http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/ar/lxml-101.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/xml.so

pack_cmd "make LUA_TOPDIR=$(pack_get --prefix lua) CFLAGS='$CFLAGS' LIBDIR=$(pack_get --LD lua)/lua/$lua_V/ so install"

