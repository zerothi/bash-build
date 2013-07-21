for v in 0.19.1 ; do
add_package http://cython.org/release/Cython-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/cython

pack_set --module-requirement $(get_parent)

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
