tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://wiki.fysik.dtu.dk/ase-files/python-ase-3.6.0.2515.tar.gz

pack_set -s $IS_MODULE

pack_set --alias ase

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --pack-module-reqs scipy)

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install
