v=2.1.1
add_package --archive fypp-$v.tar.gz \
	    https://github.com/aradi/fypp/archive/$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/bin/fypp

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"


