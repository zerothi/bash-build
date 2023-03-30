v=8.11.0
add_package --archive ipython-$v.tar.gz https://github.com/ipython/ipython/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/ipython${pV:0:1}

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
