add_package https://downloads.kwant-project.org/tinyarray/tinyarray-1.2.4.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/tinyarray-*

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set -build-mod-req cython
pack_set -mod-req numpy

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
