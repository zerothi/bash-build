add_package --build generic \
    --package luajit \
    http://luajit.org/download/LuaJIT-2.0.5.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --prefix lua)/bin/luajit

pack_cmd "make install PREFIX=$(pack_get --prefix lua) CC='$CC' CFLAGS='$CFLAGS'"

