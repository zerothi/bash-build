v=0.29.33
add_package -archive cython-$v.tar.gz \
    https://github.com/cython/cython/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/cython

pack_set -module-requirement $(get_parent)
if [[ $(pack_get -installed libffi) -eq 1 ]]; then
    pack_set -mod-req libffi
else
    pack_set -mod-req gen-libffi
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "pip install . --prefix=$(pack_get -prefix)"
