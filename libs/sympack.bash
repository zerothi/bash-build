add_package --package sympack \
	    https://github.com/symPACK/symPACK/releases/download/v1.1/symPACK-1.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libsymPACK.a
pack_set -build-mod-req build-tools
pack_set $(list -prefix ' -mod-req ' metis parmetis scotch)

tmp_flags=
if $(is_c intel) ; then
    tmp="$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    tmp_flags="$tmp_flags -DBLAS_LIBRARIES='$tmp' -DLAPACK_LIBRARIES='$tmp'"

else
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(list -LD-rp-lib $la)"
    tmp_flags="$tmp_flags -DBLAS_LIBRARIES='$tmp' -DLAPACK_LIBRARIES='$tmp'"
fi
#	 "-DMETIS_LIBRARY='$(list -LD-rp-lib metis)' -DENABLE_METIS=ON" \
#	 "-DMETIS_INCLUDE_DIR='$(pack_get -prefix metis)/include'" \

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 "-DMETIS_PREFIX='$(pack_get -prefix metis)' -DENABLE_METIS=ON" \
	 "-DPARMETIS_LIBRARY='$(list -LD-rp-lib parmetis)' -DENABLE_PARMETIS=ON" \
	 "-DPARMETIS_INCLUDE_DIR='$(pack_get -prefix parmetis)/include'" \
	 "-DSCOTCH_LIBRARY='$(list -LD-rp-lib scotch)' -DENABLE_SCOTCH=ON" \
	 "-DSCOTCH_INCLUDE_DIR='$(pack_get -prefix scotch)/include'" \
	 "-DCMAKE_BUILD_TYPE=Release $tmp_flags .."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
