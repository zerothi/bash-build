add_package https://apps.fz-juelich.de/scalasca/releases/cube/4.9/dist/cubelib-4.9.1.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/cubelib-config

pack_set -module-requirement build-tools

pack_cmd "./configure --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
