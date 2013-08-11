add_package http://labix.org/download/python-dateutil/python-dateutil-1.5.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/python_dateutil-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"


