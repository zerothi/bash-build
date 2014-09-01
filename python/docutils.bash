add_package https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/docutils

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"


