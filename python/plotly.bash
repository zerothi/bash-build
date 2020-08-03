v=4.9.0
add_package -archive plotly.py-$v.tar.gz \
	    https://github.com/plotly/plotly.py/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/python$pV/site-packages/plotly

pack_set $(list -prefix ' -module-requirement ' numpy scipy matplotlib xarray)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"
pack_cmd "cd packages/python/plotly"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"
