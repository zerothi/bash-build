v=2.0.1
add_package --package sympack \
        --directory symPACK-$v \
	https://github.com/symPACK/symPACK/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libsympack.a
pack_set -build-mod-req build-tools
pack_set $(list -prefix ' -mod-req ' metis parmetis scotch upcxx)

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

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 "-Dmetis_PREFIX='$(pack_get -prefix metis)' -DENABLE_METIS=ON" \
	 "-Dparmetis_PREFIX='$(pack_get -prefix parmetis)' -DENABLE_PARMETIS=ON" \
	 "-Dscotch_PREFIX='$(pack_get -prefix scotch)' -DENABLE_SCOTCH=ON" \
	 "-DCMAKE_BUILD_TYPE=Release $tmp_flags .."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
