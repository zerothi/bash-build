add_package https://perftools.pages.jsc.fz-juelich.de/cicd/opari2/tags/opari2-2.0.10/opari2-2.0.10.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/opari2

pack_set -module-requirement build-tools

pack_cmd "./configure --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
