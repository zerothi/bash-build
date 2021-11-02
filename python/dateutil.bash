add_package https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.8.2.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/python_dateutil-$(pack_get --version)-py$pV.egg

pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix $(get_parent))"


