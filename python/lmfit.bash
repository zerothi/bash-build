v=1.0.1
add_package --archive lmfit-$v.tar.gz --directory lmfit-py-$v \
	    https://github.com/lmfit/lmfit-py/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list --prefix ' --module-requirement ' scipy)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstallC}"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"
