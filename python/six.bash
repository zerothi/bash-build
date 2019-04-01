add_package https://pypi.python.org/packages/source/s/six/six-1.12.0.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/six-$(pack_get --version)-py$pV.egg

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"


