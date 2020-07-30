v=3.8.1
add_package http://download.osgeo.org/geos/geos-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libgeos.a
pack_set -lib -lgeos

pack_set -build-mod-req build-tools

pack_cmd "../configure --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
