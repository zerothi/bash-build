v=2.2.1
add_package --build generic \
    --archive luarocks-$v.tar.gz \
    https://github.com/keplerproject/luarocks/archive/v$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --prefix lua)/bin/luarocks

[ $(pack_installed build-tools) -eq 1 ] && \
    pack_set --module-requirement build-tools

# Configure the package
pack_set --command "./configure" \
    --command-flag "--lua-version=$lua_V" \
    --command-flag "--with-lua=$(pack_get --prefix lua)" \
    --command-flag "--prefix=$(pack_get --prefix lua)"

# Make lua package
pack_set --command "make build"
pack_set --command "make install"

