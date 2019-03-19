add_package --build generic --package gen-libxml2 \
	    ftp://xmlsoft.org/libxml2/libxml2-2.9.8.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libxml2.so

pack_set --module-requirement gen-zlib

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--with-python=no" \
	 "--with-zlib=$(pack_get --prefix gen-zlib)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libxml2.test 2>&1"
pack_cmd "make install"
pack_store libxml2.test

pack_cmd "pushd $(pack_get --prefix)/include"
pack_cmd "ln -s libxml2/libxml"
pack_cmd "popd"
