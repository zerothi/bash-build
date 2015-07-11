v=3.2.0
add_package https://pypi.python.org/packages/source/i/ipython/ipython-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/ipython${pV:0:1}

pack_set --command "$(get_parent_exec) setup.py build ${pNumpyInstall%--fcomp*}"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
