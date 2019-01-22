v=3.0.4
add_package --build generic \
    --archive luarocks-$v.tar.gz \
    https://github.com/keplerproject/luarocks/archive/v$v.tar.gz

pack_set --module-requirement lua
pack_set -s $BUILD_TOOLS

pack_set --install-query $(pack_get --prefix lua)/bin/luarocks

# Configure the package
pack_cmd "./configure" \
        "--lua-version=$lua_V" \
        "--with-lua=$(pack_get --prefix lua)" \
        "--prefix=$(pack_get --prefix lua)"

# Make lua package
pack_cmd "make build"
pack_cmd "make install"

# Now add packages
pack_cmd "luarocks install luaposix"
