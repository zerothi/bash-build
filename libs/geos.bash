v=3.10.0
add_package http://download.osgeo.org/geos/geos-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libgeos.a
pack_set -lib -lgeos

pack_set -build-mod-req build-tools

tmp=
if $(is_c intel) ; then
    tmp="$tmp CXXFLAGS='$CXXFLAGS -std=c++11'"
fi

pack_cmd "unset LDFLAGS"
pack_cmd "../configure $tmp --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
