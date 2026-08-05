add_package https://perftools.pages.jsc.fz-juelich.de/cicd/otf2/tags/otf2-3.2/otf2-3.2.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/otf2-config

pack_set -module-requirement build-tools

pack_cmd "./configure --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
