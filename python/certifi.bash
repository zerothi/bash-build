v=2021.10.8
add_package --version $v https://pypi.python.org/packages/source/c/certifi/certifi-$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/certifi-$(pack_get --version)-py$pV.egg

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"


