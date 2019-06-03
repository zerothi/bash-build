add_package https://launchpad.net/libpsml/trunk/1.1/+download/libpsml-1.1.7.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libpsml.so

pack_set --module-requirement xmlf90
pack_set --lib -lpsml

pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)" \
	 "--with-xmlf90=$(pack_get --prefix xmlf90)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
