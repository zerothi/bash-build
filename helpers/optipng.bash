add_package --build generic \
	    http://prdownloads.sourceforge.net/optipng/optipng-0.7.5.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/optipng

# Install commands that it should run
pack_cmd "./configure CC=$CC CFLAGS='$CFLAGS'" \
	 "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
