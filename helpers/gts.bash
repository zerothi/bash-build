v=0.7.6
add_package --build generic \
	    https://sourceforge.net/projects/gts/files/gts/$v/gts-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libgts.a

pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make"
pack_cmd "make install"
