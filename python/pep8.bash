v=1.6.2
add_package https://pypi.python.org/packages/source/p/pep8/pep8-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pep8

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
