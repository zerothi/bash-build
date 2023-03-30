v=0.20.0
add_package -archive scikit-image-$v.tar.gz \
	    https://github.com/scikit-image/scikit-image/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/skimage

# Add requirments when creating the module
pack_set $(list -prefix ' -module-requirement ' dask networkx cython scipy pywavelets matplotlib imageio)

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"

# Install commands that it should run
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
