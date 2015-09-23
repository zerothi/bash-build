v=4.0.0
add_package --archive ipython-$v.tar.gz https://github.com/ipython/ipython/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/ipython${pV:0:1}

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
