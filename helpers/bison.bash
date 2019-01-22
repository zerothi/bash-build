# apt-get m4
add_package --build generic http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --install-query $(pack_get --prefix)/bin/bison

pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
