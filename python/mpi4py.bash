add_package https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-1.3.1.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement openmpi

pack_set --install-query $(pack_get --library-path)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"


