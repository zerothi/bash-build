v=1.4.6
add_package --build generic \
    --archive LDoc-$v.tar.gz \
    --package ldoc \
    https://github.com/stevedonovan/LDoc/archive/$v.tar.gz

pack_set --module-requirement penlight

pack_set --install-query $(pack_get --LD lua)/lua/$lua_V/ldoc

# Configure the package
pack_cmd "make install"

