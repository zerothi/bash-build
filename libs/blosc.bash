v=1.21.2
add_package -archive c-blosc-$v.tar.gz -package blosc -version $v \
	    https://github.com/Blosc/c-blosc/archive/refs/tags/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -mod-req zlib
pack_set -install-query $(pack_get -prefix)/include/blosc.h
pack_set -lib -lblosc

opts=
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DPREFER_EXTERNAL_ZLIB=ON"

pack_cmd cmake $opts ..
pack_cmd cmake --build . $(get_make_parallel)
pack_cmd cmake --build . --target install
