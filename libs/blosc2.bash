v=2.8.0
add_package -archive c-blosc2-$v.tar.gz -package blosc2 -version $v \
	    https://github.com/Blosc/c-blosc2/archive/refs/tags/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -mod-req zlib
pack_set -install-query $(pack_get -LD)/libblosc2.so
pack_set -lib -lblosc2

opts=
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DPREFER_EXTERNAL_ZLIB=ON"

pack_cmd cmake $opts ..
pack_cmd cmake --build . $(get_make_parallel)
pack_cmd cmake --build . --target install
