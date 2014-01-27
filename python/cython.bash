v=0.20
add_package http://cython.org/release/Cython-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/cython

pack_set --module-requirement $(get_parent)
pack_set --module-requirement ffi

# We need to create the directory WTF
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
