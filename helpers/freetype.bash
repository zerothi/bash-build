add_package --build generic --alias gen-freetype --package gen-freetype \
    http://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/freetype-config

# pkg-config will get the correct library
pack_set --module-requirement gen-libpng

# Configure calls setup
pack_cmd "./configure --prefix $(pack_get --prefix)"
pack_cmd "make"
pack_cmd "make install"

