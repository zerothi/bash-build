v=3.7.0
add_package -build generic \
	    -archive luarocks-$v.tar.gz \
	    https://github.com/luarocks/luarocks/archive/refs/tags/v$v.tar.gz

pack_set -build-mod-req build-tools
pack_set -module-requirement lua

pack_set -install-query $(pack_get -prefix lua)/bin/luarocks

# Configure the package
pack_cmd "./configure" \
        "--lua-version=$lua_V" \
        "--with-lua=$(pack_get -prefix lua)" \
        "--prefix=$(pack_get -prefix lua)"

# Make lua package
pack_cmd "make build"
pack_cmd "make install"


# Add installations
add_package luarocks-packages.local
pack_set -directory .

pack_set -module-requirement lua

# Now add packages
pack_cmd "[ ! -d $(pack_get -prefix lua)/lib/luarocks/rocks-$lua_V/luaposix ] && luarocks install luaposix || echo 'luaposix already installed'"
