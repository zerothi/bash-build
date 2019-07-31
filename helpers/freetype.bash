add_package -build generic -alias gen-freetype -package gen-freetype \
    http://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/freetype-config

# pkg-config will get the correct library
pack_set -module-requirement gen-libpng

pack_cmd "./configure --prefix $(pack_get -prefix) --enable-freetype-config"
pack_cmd "make"
pack_cmd "make install"

# Sadly some installations does not check the correct
# place for the ft2build.h header
pack_cmd "pushd $(pack_get -prefix)/include ; ln -s freetype2/ft2build.h ; ln -s freetype2/freetype freetype ; popd"

