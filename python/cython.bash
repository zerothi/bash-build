v=0.22.1
add_package http://cython.org/release/Cython-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/cython

pack_set --module-requirement $(get_parent)
pack_set --module-requirement libffi

# We need to create the directory WTF
pack_set --command "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"
