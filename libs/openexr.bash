v=3.1.3
add_package -archive openexr-$v.tar.gz \
	    https://github.com/AcademySoftwareFoundation/openexr/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools

pack_set -mod-req boost -mod-req zlib

pack_set -install-query $(pack_get -LD)/libIex.so

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 -DBOOST_ROOT=$(pack_get -prefix boost) \
	 -DPYILMBASE_ENABLE=0 \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"



