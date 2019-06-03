v=3.1.2
add_package --build generic --package wxwidgets \
	    --archive wxWidgets-$v.tar.bz2 \
	    https://github.com/wxWidgets/wxWidgets/releases/download/v$v/wxWidgets-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/wx-config

pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
