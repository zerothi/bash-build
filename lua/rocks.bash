v=2.2.1
add_package --build generic \
    --archive luarocks-$v.tar.gz \
    https://github.com/keplerproject/luarocks/archive/v$v.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --prefix lua)/bin/luarocks

[ $(pack_installed build-tools) -eq 1 ] && \
    pack_set --module-requirement build-tools

# Configure the package
pack_cmd "./configure" \
        "--lua-version=$lua_V" \
        "--with-lua=$(pack_get --prefix lua)" \
        "--prefix=$(pack_get --prefix lua)"

# Make lua package
pack_cmd "make build"
pack_cmd "make install"

