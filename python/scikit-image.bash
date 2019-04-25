[ "x${pV:0:1}" == "x2" ] && return 0
v=0.15.0  
add_package --archive scikit-image-$v.tar.gz \
	    https://github.com/scikit-image/scikit-image/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

# Add requirments when creating the module
pack_set --module-requirement dask \
    --module-requirement networkx \
    --module-requirement scipy \
    --module-requirement pywavelets

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
