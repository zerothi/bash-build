add_package https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-1.3.1.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement mpi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"


