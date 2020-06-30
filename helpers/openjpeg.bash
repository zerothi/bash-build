v=2.3.1
add_package -build generic -archive openjpeg-$v.tar.gz \
	    https://github.com/uclouvain/openjpeg/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set -install-query $(pack_get -prefix)/bin/opj_compress

pack_cmd cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) \
	 -DCMAKE_BUILD_TYPE="Release" \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
