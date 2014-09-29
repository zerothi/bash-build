add_package --build generic \
    --directory Penlight-1.3.1 \
    --archive penlight-1.3.1.tar.gz \
    https://github.com/stevedonovan/Penlight/archive/1.3.1.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/pl

pack_set --command "cd lua"
pack_set --command "cp -rf pl $(pack_get --LD lua)/lua/$lua_V/"
