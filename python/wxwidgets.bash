v=3.1.0
add_package --version $v --package wxwidgets \
	    https://github.com/wxWidgets/wxWidgets/releases/download/v$v/wxWidgets-$v.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_cmd "../configure --prefix=$(pack_get --prefix)"
pack_cmd "make"
pack_cmd "make install"

