add_package https://pypi.python.org/packages/source/s/setuptools/setuptools-18.3.2.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/setuptools.pth

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"


