v=3.1.2
add_package https://github.com/OSGeo/gdal/releases/download/v$v/gdal-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libgdal.a
pack_set -lib -lgdal

pack_set $(list -prefix ' -mod-req ' curl expat libxml2 sqlite openexr netcdf-serial proj sfcgal geos qhull)

# Sadly, the proj linker test does not add libcurl and its dependencies
pack_cmd "./configure" \
	 "--with-curl=$(pack_get -prefix curl)" \
	 "--with-expat=$(pack_get -prefix expat)" \
	 "--with-xml2=yes" \
	 "--with-libz=$(pack_get -prefix zlib)" \
	 "--with-sqlite3=$(pack_get -prefix sqlite)" \
	 "--with-proj=$(pack_get -prefix proj)" \
	 "--with-hdf5=$(pack_get -prefix hdf5-serial)" \
	 "--with-netcdf=$(pack_get -prefix netcdf-serial)" \
	 "--with-sfcgal=yes" \
	 "--with-qhull=yes" \
	 "--with-geos=yes" \
	 "--with-exr=yes" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
