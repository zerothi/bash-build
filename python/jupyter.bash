v=5.7.9
add_package --archive jupyter-$v.tar.gz \
	    --directory notebook-$v \
	    https://github.com/jupyter/notebook/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/jupyter

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
