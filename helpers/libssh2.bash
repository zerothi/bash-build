add_package -build generic \
	    https://www.libssh2.org/download/libssh2-1.10.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools
pack_set -mod-req openssl

pack_set -install-query $(pack_get -LD)/libssh2.so

pack_cmd "../configure" \
	 "--with-libssl-prefix=$(pack_get -prefix openssl)" \
	 "--with-libz-prefix=$(pack_get -prefix gen-zlib)" \
	 "--prefix=$(pack_get -prefix)"
pack_cmd "make"
pack_cmd "make check > libssh2.test || echo forced"
pack_cmd "make install"
pack_store libssh2.test
