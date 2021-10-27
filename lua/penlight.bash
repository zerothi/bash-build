v=1.11.0
add_package --build generic \
	    --package penlight \
	    --archive Penlight-$v.tar.gz \
	    https://github.com/lunarmodules/Penlight/archive/$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/pl

pack_cmd "cd lua"
pack_cmd "cp -rf pl $(pack_get --LD lua)/lua/$lua_V/"
