v=1.7.1
add_package https://pypi.python.org/packages/source/p/pep8/pep8-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pep8

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
