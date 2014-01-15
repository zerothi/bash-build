if [ "x${pV:0:1}" == "x3" ]; then
	add_package https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.2.tar.gz
else
	add_package http://labix.org/download/python-dateutil/python-dateutil-1.5.tar.gz
fi	

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/python_dateutil-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"


