v=3.0.0
add_package https://github.com/OSGeo/gdal/releases/download/v$v/gdal-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libgdal.a
pack_set -lib -lgdal

pack_set -mod-req proj
pack_set $(list -prefix ' -module-requirement ' expat libxml2 netcdf-serial sfcgal geos)

pack_cmd "./configure" \
	 "--with-proj=$(pack_get -prefix proj)" \
	 "--with-expat=$(pack_get -prefix expat)" \
	 "--with-xml2=$(pack_get -prefix libxml2)" \
	 "--with-libz=$(pack_get -prefix zlib)" \
	 "--with-sfcgal=$(pack_get -prefix sfcgal)" \
	 "--with-geos=$(pack_get -prefix geos)" \
	 "--with-hdf5=$(pack_get -prefix hdf5-serial)" \
	 "--with-netcdf=$(pack_get -prefix netcdf-serial)" \
	 "--prefix $(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
