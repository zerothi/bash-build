add_package \
    --package lua-filesystem \
    --directory luafilesystem-master \
    --archive lua-filesystem.zip \
    https://github.com/keplerproject/luafilesystem/archive/master.zip

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/lfs.so

# Correct the installation compilation
pack_set --command "rm config"
pack_set --command "echo '' > config"
pack_set --command "echo '' > config"
pack_set --command "sed -i '1 a\
PREFIX = $(pack_get --install-prefix lua)\n\
LUA_LIBDIR = \$(PREFIX)/lib/lua/$lua_V\n\
LUA_INC =\$(PREFIX)/include\n\
LIB_OPTION = -shared\n\
\#LIBNAME = \$T.so.\$V\n\
WARN = \n\
INCS = -I\$(LUA_INC)\n\
CFLAGS = $CFLAGS \$(INCS)\n\
CC = $CC' config"

# Make lua package
pack_set --command "make"

# Make install lua
pack_set --command "make install"

# Copy the header to the correct placement
pack_set --command "cp src/lfs.h $(pack_get --install-prefix lua)/include/"
