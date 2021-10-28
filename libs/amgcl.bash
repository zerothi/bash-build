v=1.4.2
add_package -archive amgcl-$v.tar.gz https://github.com/ddemidov/amgcl/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set $(list -p '-mod-req ' mpi boost metis)

pack_set -install-query $(pack_get -prefix)/include/amgcl/amg.hpp

tmp_flags=
if $(is_c intel) ; then
    tmp="$MKL_LIB -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    tmp_flags="$tmp_flags -DBLAS_LIBRARIES='$tmp'"

else
    blas=$(pack_choice -i linalg)
    pack_set -module-requirement $blas
    tmp="$(list -LD-rp-lib $blas)"
    tmp_flags="$tmp_flags -DBLAS_LIBRARIES='$tmp'"
fi

# Install commands that it should run
pack_cmd "cmake $tmp_flags -DAMGCL_HAVE_FORTRAN=1" \
	 "-DBOOST_ROOT=$(pack_get -prefix boost)" \
	 "-DMETIS_LIBRARY='$(list -LD-rp-lib metis)'" \
	 "-DMETIS_INCLUDES='$(pack_get -prefix metis)/include'" \
	 "-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) .."

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"




