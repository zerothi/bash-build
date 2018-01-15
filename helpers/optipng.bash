add_package --build generic \
	    http://prdownloads.sourceforge.net/optipng/optipng-0.7.7.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/optipng

# Install commands that it should run
pack_cmd "CC=$CC CFLAGS='$CFLAGS' ./configure" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
