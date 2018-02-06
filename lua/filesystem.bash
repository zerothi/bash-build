v=1_6_3
add_package --build generic \
	    --package luafilesystem \
	    -archive luafilesystem-v_$v.tar.gz \
	    -version ${v//_/.} \
	    https://github.com/keplerproject/luafilesystem/archive/v_$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/lfs.so

# Correct the installation compilation
pack_cmd "rm config"
pack_cmd "echo '' > config"
pack_cmd "echo '' > config"
pack_cmd "sed -i '1 a\
PREFIX = $(pack_get --prefix lua)\n\
LUA_LIBDIR = \$(PREFIX)/lib/lua/$lua_V\n\
LUA_INC =\$(PREFIX)/include\n\
LIB_OPTION = -shared\n\
\#LIBNAME = \$T.so.\$V\n\
WARN = \n\
INCS = -I\$(LUA_INC)\n\
CFLAGS = $CFLAGS \$(INCS)\n\
CC = $CC' config"

# Make lua package
pack_cmd "make"

# Make install lua
pack_cmd "make install"

# Copy the header to the correct placement
pack_cmd "cp src/lfs.h $(pack_get --prefix lua)/include/"

