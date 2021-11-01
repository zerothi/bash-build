v=4.2.0
add_package --archive sphinx-$v.tar.gz \
    https://github.com/sphinx-doc/sphinx/archive/$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/Sphinx-$(pack_get --version)-py$pV.egg

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
