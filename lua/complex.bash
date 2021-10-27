add_package --build generic \
    --version $lua_V \
    http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/ar/lcomplex-100.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/complex.so

pack_cmd "make LUA_TOPDIR=$(pack_get --prefix lua) CFLAGS='$CFLAGS' LIBDIR=$(pack_get --LD lua)/lua/$lua_V/ so install"
