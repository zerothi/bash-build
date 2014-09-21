add_package --build generic --alias gen-freetype --package gen-freetype \
    http://download.savannah.gnu.org/releases/freetype/freetype-2.5.3.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/freetype-config
pack_set --host-reject hemera

# Install commands that it should run
pack_set --command "sed -i -e 's:^TOP_DIR.*:TOP_DIR = .:' Makefile"
pack_set --command "make setup unix"
pack_set --command "make install"

