add_package https://downloads.kwant-project.org/tinyarray/tinyarray-1.2.3.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --module-requirement numpy \
    --module-requirement cython

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
