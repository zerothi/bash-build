add_package http://apps.fz-juelich.de/scalasca/releases/scalasca/2.4/dist/scalasca-2.4.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/scalasca

pack_set --module-requirement build-tools
pack_set --module-requirement mpi
pack_set --module-requirement scorep

pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
