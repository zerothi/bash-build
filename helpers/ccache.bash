v=3.7.11
add_package -build generic \
	    https://github.com/ccache/ccache/releases/download/v$v/ccache-$v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set -install-query $(pack_get -prefix)/bin/ccache

pack_cmd "../configure --prefix=$(pack_get -prefix)"
pack_cmd "make"
pack_cmd "make install"
