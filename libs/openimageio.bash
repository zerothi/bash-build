v=2.1.15.0
add_package -package openimageio -archive oiio-Release-$v.tar.gz \
	    https://github.com/OpenImageIO/oiio/archive/Release-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools

pack_set -mod-req ffmpeg -mod-req boost -mod-req openexr
pack_set -mod-req hdf5-serial

pack_set -install-query $(pack_get -prefix)/bin/oiiotool

# This requires ffmpeg as a shared library
pack_cmd "unset LDFLAGS"
pack_cmd cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) \
	 -DBOOST_ROOT=$(pack_get -prefix boost) \
	 -DOpenEXR_ROOT=$(pack_get -prefix openexr) \
	 -DHDF5_ROOT=$(pack_get -prefix hdf5-serial) \
	 -DUSE_PYTHON=0 \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"



