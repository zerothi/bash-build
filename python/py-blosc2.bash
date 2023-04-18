v=2.2.0
add_package -archive python-blosc2-$v.tar.gz -package py-blosc2 -version $v \
       https://github.com/Blosc/python-blosc2/archive/refs/tags/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get -LD)/python$pV/site-packages/blosc2

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_set -build-mod-req cython
pack_set --mod-req blosc2 -mod-req numpy

pack_cmd "SKBUILD_CONFIGURE_OPTIONS='-DUSE_SYSTEM_BLOSC2=ON' $_pip_cmd . --prefix=$(pack_get -prefix)"
