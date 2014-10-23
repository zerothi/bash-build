v=2.3.0
add_package http://archive.ipython.org/release/$v/ipython-$v.tar.gz

tmp=
[ "x${pV:0:1}" == "x3" ] && tmp=3
pack_set --install-query $(pack_get --prefix $(get_parent))/bin/ipython$tmp

pack_set --command "$(get_parent_exec) setup.py build ${pNumpyInstall%--fcomp*}"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
