v=6.5.3
add_package --archive jupyter-$v.tar.gz \
	    --directory notebook-$v \
	    https://github.com/jupyter/notebook/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/jupyter

# Install commands that it should run
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
