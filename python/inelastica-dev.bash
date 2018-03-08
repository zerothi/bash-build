[ "x${pV:0:1}" == "x3" ] && return 0

add_package --package Inelastica-dev --version 0 \
	    https://github.com/tfrederiksen/inelastica.git

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query always-install-this-module

pack_set $(list --prefix ' --module-requirement ' scipy netcdf4py)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"
