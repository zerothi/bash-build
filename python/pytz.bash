add_package https://pypi.python.org/packages/source/p/pytz/pytz-2018.9.tar.bz2

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/pytz-$(pack_get --version)-py$pV.egg

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
