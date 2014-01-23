v=0.20
add_package http://cython.org/release/Cython-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/cython

pack_set --module-requirement $(get_parent)

if [ $(vrs_cmp $(pack_get --version $(get_parent)) 3.0.0) -ge 0 ]; then
    pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages"
fi

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
