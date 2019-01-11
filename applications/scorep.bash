add_package https://www.vi-hps.org/upload/packages/scorep/scorep-4.1.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/scorep

pack_set --module-requirement build-tools
pack_set --module-requirement mpi

pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
