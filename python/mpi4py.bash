add_package http://mpi4py.googlecode.com/files/mpi4py-1.3.1.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement $(get_parent) \
    --module-requirement openmpi

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"


