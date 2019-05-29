v=3.0.0
add_package https://github.com/OSGeo/gdal/releases/download/v$v/gdal-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libgdal.a
pack_set -lib -lgdal
pack_set -mod-req proj

pack_cmd "./configure" \
	 "--with-proj=$(pack_get -prefix proj)" \
	 "--prefix $(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
