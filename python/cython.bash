v=0.23.2
add_package http://cython.org/release/Cython-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/cython

pack_set --module-requirement $(get_parent)
pack_set --module-requirement libffi

# We need to create the directory WTF
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
