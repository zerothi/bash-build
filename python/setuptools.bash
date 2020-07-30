v=49.1.0
add_package --archive setuptools-$v.tar.gz \
	    https://github.com/pypa/setuptools/archive/v$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/setuptools.pth

pack_cmd "$(get_parent_exec) bootstrap.py"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"


