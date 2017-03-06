add_package --build generic \
	    https://github.com/libgd/libgd/releases/download/gd-2.2.4/libgd-2.2.4.tar.xz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libgd.a

# Install commands that it should run
pack_cmd "CC=$CC CFLAGS='$CFLAGS' ./configure" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "sed -i -e \"/math.h/a#include <limits.h>\n\" src/gd_gd2.c"
# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
