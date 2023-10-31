# First install zlib, which is a simple library
v=1.0
add_package -build generic \
	https://ftp.gnu.org/gnu/gprofng-gui/gprofng-gui-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -prefix)/bin/gprofng

pack_set -mod-req jdk

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > gprofng-gui.test 2>&1"
pack_cmd "make install"
pack_store gprofng-gui.test
