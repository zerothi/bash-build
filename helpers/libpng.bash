add_package -build generic -alias gen-libpng -package gen-libpng \
	    https://download.sourceforge.net/libpng/libpng-1.6.36.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libpng.a

pack_set -module-requirement gen-zlib

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get -prefix)" \
	 "--with-zlib-prefix=$(pack_get -prefix gen-zlib)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libpng.test 2>&1"
pack_cmd "make install"
pack_store libpng.test
