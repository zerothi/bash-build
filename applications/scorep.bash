add_package https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-10.1/scorep-10.1.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/scorep

pack_set -module-requirement build-tools
pack_set -module-requirement mpi
pack_set -module-requirement otf2
pack_set -module-requirement opari2
pack_set -module-requirement cubelib
pack_set -module-requirement cubew

pack_cmd "../configure" \
	 "--prefix=$(pack_get -prefix)" \
	 "--with-libbfd=$(pack_get -prefix build-tools)" \
	 "--with-cubelib=$(pack_get -prefix cubelib)" \
	 "--with-cubew=$(pack_get -prefix cubew)" \
	 "--with-otf2=$(pack_get -prefix otf2)" \
	 "--with-opari2=$(pack_get -prefix opari2)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
