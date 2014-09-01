add_package https://pypi.python.org/packages/source/p/pytz/pytz-2014.4.tar.bz2

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/pytz-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"