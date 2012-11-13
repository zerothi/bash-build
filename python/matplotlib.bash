tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://github.com/downloads/matplotlib/matplotlib/matplotlib-1.2.0.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement $(get_parent) \
    --module-requirement numpy

pack_set --command "$(get_parent_exec) setup.py config"
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install
