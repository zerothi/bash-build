v=0.9.11
add_package --archive lmfit-$v.tar.gz \
	    https://github.com/lmfit/lmfit-py/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix ' --module-requirement ' uncertainties asteval scipy)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"
