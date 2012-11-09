tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://mpi4py.googlecode.com/files/mpi4py-1.3.tar.gz
module load $(pack_get --module-name openmpi)

pack_set -s $IS_MODULE

pack_set --module-requirement openmpi

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement $(get_parent)

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install

module unload $(pack_get --module-name openmpi)
