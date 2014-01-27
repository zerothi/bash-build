add_package https://pypi.python.org/packages/source/p/pycparser/pycparser-2.10.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/pycparser

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"


