v=1.4.1
add_package -package sfcgal \
	    https://gitlab.com/Oslandia/SFCGAL/-/archive/v$v/SFCGAL-v$v.tar.bz2


pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/sfcgal-config
pack_set -lib -lSFCGAL

pack_set -build-mod-req build-tools
pack_set -mod-req cgal

tmp_flags="-DCGAL_DIR='$(pack_get -prefix cgal)'"
tmp_flags="$tmp_flags -DCGAL_INCLUDE_DIRS='$(pack_get -prefix cgal)/include'"
tmp_flags="$tmp_flags -DCGAL_LIBRARY_DIRS='$(pack_get -L cgal)'"
tmp_flags="$tmp_flags -DBOOST_ROOT='$(pack_get -prefix boost)'"
tmp_flags="$tmp_flags -DBoost_INCLUDE_DIR='$(pack_get -prefix boost)/include'"

if $(is_c gnu) ; then
    # We have stuff locally installed
    tmp_flags="$tmp_flags MPFR_DIR='$(pack_get -prefix gcc[$(get_c -v)])'"
    tmp_flags="$tmp_flags -DMPFR_LIBRARIES='$(list -LD-rp gcc[$(get_c -v)]) -lmpfr'"
    tmp_flags="$tmp_flags -DMPFR_INCLUDE_DIR='$(pack_get -prefix gcc[$(get_c -v)])/include'"
    tmp_flags="$tmp_flags GMP_DIR='$(pack_get -prefix gcc[$(get_c -v)])'"
    tmp_flags="$tmp_flags -DGMP_LIBRARIES='$(list -LD-rp gcc[$(get_c -v)]) -lgmp'"
    tmp_flags="$tmp_flags -DGMP_INCLUDE_DIR='$(pack_get -prefix gcc[$(get_c -v)])/include'"
fi

pack_cmd "cmake $tmp_flags -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) ."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
