add_package --package ipi-dev --version 0 \
	    https://github.com/i-pi/i-pi.git

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query always-install-this-module

pack_set $(list --prefix ' --module-requirement ' scipy)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"

# env.sh file
pack_cmd "cp env.sh $(pack_get --prefix)/"
pack_set --module-opt "--set-ENV IPI_ENV=$(pack_get --prefix)/env.sh"

pack_cmd "mkdir -p $(pack_get --prefix)/source"
pack_cmd "cd drivers/f90"
pack_cmd "cp Makefile driver.f90 fsockets.f90 fsockets_pure.f90 sockets.c $(pack_get --prefix)/source/"
