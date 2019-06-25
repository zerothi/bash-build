add_package -build generic https://curl.haxx.se/download/curl-7.65.1.tar.xz

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set -build-mod-req build-tools
pack_set $(list -prefix '-mod-req ' libssh2 openssl)

pack_set -install-query $(pack_get -prefix)/lib/libcurl.so

pack_cmd "../configure" \
	 "--with-zlib=$(pack_get -prefix gen-zlib)" \
	 "--with-ssl=$(pack_get -prefix openssl)" \
	 "--with-libssh2=$(pack_get -prefix libssh2)" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
