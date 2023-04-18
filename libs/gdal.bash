v=3.6.3
add_package https://github.com/OSGeo/gdal/releases/download/v$v/gdal-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/gdal-config
pack_set -lib -lgdal

pack_set $(list -prefix ' -mod-req ' curl expat libxml2 sqlite openexr netcdf-serial proj sfcgal geos qhull blosc)

opts=
opts="$opts -DGDAL_USE_BLOSC=ON"
opts="$opts -DGDAL_USE_CURL=ON"
opts="$opts -DGDAL_USE_PROJ=ON"
opts="$opts -DGDAL_USE_EXPACT=ON"
opts="$opts -DGDAL_USE_GEOS=ON"
opts="$opts -DGDAL_USE_HDF5=ON"
opts="$opts -DGDAL_USE_JPEG=ON"
opts="$opts -DGDAL_USE_LIBXML2=ON"
opts="$opts -DGDAL_USE_NETCDF=ON"
opts="$opts -DGDAL_USE_OPENEXR=ON"
opts="$opts -DGDAL_USE_PCRE2=ON"
opts="$opts -DGDAL_USE_QHULL=ON"
opts="$opts -DGDAL_USE_SQLITE3=ON"
opts="$opts -DGDAL_USE_SFCGAL=ON"
opts="$opts -DGDAL_USE_ZLIB=ON"
flags=
flags="$flags HDF5_LIBRARIES='$(list -LD-rp hdf5-serial) $(pack_get -libs hdf5-serial)'"
flags="$flags HDF5_INCLUDE_DIRS='$(pack_get -prefix hdf5-serial)/include'"
flags="$flags BLOSC_ROOT=$(pack_get -prefix blosc)"
flags="$flags OpenEXR_ROOT=$(pack_get -prefix openexr)"

pack_cmd "$flags cmake -Bbuild-tmp $opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) -S."
pack_cmd "cmake --build build-tmp $(get_make_parallel)"
pack_cmd "cmake --build build-tmp --target test 2>&1 > gdal.test"
pack_cmd "cmake --build build-tmp --target install"
pack_store gdal.test
