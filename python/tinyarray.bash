v=1.2.4
add_package -version $v \
    -package tinyarray \
    https://gitlab.kwant-project.org/kwant/tinyarray/-/archive/v1.2.4/tinyarray-v1.2.4.tar.bz2

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/tinyarray-*

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set -build-mod-req cython
pack_set -mod-req numpy

pack_cmd "echo '$v' > version"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
