v=1.11.0
add_package -archive python-blosc-$v.tar.gz -package py-blosc -version $v \
       https://github.com/Blosc/python-blosc/archive/refs/tags/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get -LD)/python$pV/site-packages/blosc

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_set -build-mod-req cython
pack_set -mod-req blosc -mod-req numpy

opts=
opts="$opts SKBUILD_CONFIGURE_OPTIONS='-DBlosc_INCLUDE_DIR=$(pack_get -prefix blosc)/include -DBlosc_LIBRARY=blosc'"
pack_cmd "USE_SYSTEM_BLOSC=1 $opts $_pip_cmd . --prefix=$(pack_get -prefix)"
