v=0.2.3
add_package --archive sgdml-$v.tar.gz \
	    https://github.com/stefanch/sGDML/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/sgdml
pack_set -module-requirement numpy
pack_set -module-requirement ase

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"
