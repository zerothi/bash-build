add_package --package sphinx https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.2.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/Sphinx-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
