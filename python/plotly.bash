v=5.14.0
add_package -alias plotly -archive plotly.py-$v.tar.gz \
	    https://github.com/plotly/plotly.py/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/plotly

pack_set $(list -prefix ' -module-requirement ' numpy scipy matplotlib xarray)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"
pack_cmd "cd packages/python/plotly"
pack_cmd "sed -i -e 's:sys.path.append(:sys.path.insert(0, :' setup.py"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
