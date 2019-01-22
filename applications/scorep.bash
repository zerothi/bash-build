add_package https://www.vi-hps.org/upload/packages/scorep/scorep-4.1.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/scorep

pack_set --module-requirement build-tools
pack_set --module-requirement mpi
pack_set --module-requirement otf2
pack_set --module-requirement opari2

pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-otf2=$(pack_get --prefix otf2)" \
	 "--with-opari2=$(pack_get --prefix opari2)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
