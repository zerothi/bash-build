add_package --package sympack \
	    https://github.com/symPACK/symPACK/releases/download/v1.1/symPACK-1.1.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR -s $BUILD_TOOLS

pack_set -install-query $(pack_get -LD)/libsymPACK.a
pack_set $(list -prefix ' -mod-req ' metis parmetis scotch)

tmp_flags=
if $(is_c intel) ; then
    tmp_flags="-DBLAS_DIR=$MKLROOT -DLAPACK_DIR=$MKLROOT"

else
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_flags="-DBLAS_LIBRARIES='$(list -LD-rp $la) $(pack_get -lib $la)' -DLAPACK_DIR=$(pack_get -prefix $la)"
fi

pack_cmd "cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 "-DMETIS_DIR=$(pack_get -prefix metis) -DENABLE_METIS=ON" \
	 "-DPARMETIS_DIR=$(pack_get -prefix parmetis) -DENABLE_PARMETIS=ON" \
	 "-DSCOTCH_DIR=$(pack_get -prefix scotch) -DENABLE_SCOTCH=ON" \
	 "-DCMAKE_BUILD_TYPE=Release $tmp_flags .."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
