v=18.1
add_package --archive pip-$v.tar.gz \
     https://github.com/pypa/pip/archive/$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/bin/pip

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
