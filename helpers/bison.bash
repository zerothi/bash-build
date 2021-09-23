# apt-get m4
add_package --build generic http://ftp.gnu.org/gnu/bison/bison-3.8.1.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/bison
pack_set -build-mod-req build-tools

pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
