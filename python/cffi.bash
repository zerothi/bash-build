# Package requires:
#  libffi-dev
v=1.15.1
add_package https://pypi.python.org/packages/source/c/cffi/cffi-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/cffi

pack_set -build-mod-req cython

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix)"

