v=5.3
add_package --package cgal https://github.com/CGAL/cgal/releases/download/v$v/CGAL-$v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -prefix)/bin/cgal_create_cmake_script
pack_set -lib -lcgal

pack_set -build-mod-req build-tools
pack_set $(list -prefix '-mod-req ' zlib boost eigen metis)

tmp_flags=
tmp_flags="$tmp_flags -DWITH_ZLIB=ON"

tmp_flags="$tmp_flags -DZLIB_LIBRARIES='$(list -LD-rp zlib) -lz'"
tmp_flags="$tmp_flags -DZLIB_INCLUDE_DIR='$(pack_get -prefix zlib)/include'"
tmp_flags="$tmp_flags -DBoost_INCLUDE_DIR='$(pack_get -prefix boost)/include'"
tmp_flags="$tmp_flags -DEIGEN3_INCLUDE_DIR='$(pack_get -prefix eigen)/include'"
tmp_flags="$tmp_flags -DMETIS_INCLUDE_DIR='$(pack_get -prefix metis)/include'"
tmp_flags="$tmp_flags -DMETIS_LIBRARIES='$(list -LD-rp-lib metis)'"

if $(is_c gnu) ; then
    # We have stuff locally installed
    tmp_flags="$tmp_flags -DMPFR_LIBRARIES='$(list -LD-rp gcc[$(get_c -v)]) -lmpfr'"
    tmp_flags="$tmp_flags -DMPFR_INCLUDE_DIR='$(pack_get -prefix gcc[$(get_c -v)])/include'"
    tmp_flags="$tmp_flags -DGMP_LIBRARIES='$(list -LD-rp gcc[$(get_c -v)]) -lgmp'"
    tmp_flags="$tmp_flags -DGMP_INCLUDE_DIR='$(pack_get -prefix gcc[$(get_c -v)])/include'"
fi

pack_cmd "cmake $tmp_flags -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) .."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
