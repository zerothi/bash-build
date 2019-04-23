add_package http://p4est.github.io/release/p4est-2.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list -prefix '-mod-req ' mpi metis petsc-d)

pack_set -install-query $(pack_get -LD)/libp4est.a
pack_set -lib -lp4est

tmp_flags=

if $(is_c intel) ; then
    tmp_flags="$tmp_flags --with-blas='$MKL_LIB -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential'"
    tmp_flags="$tmp_flags --with-lapack='$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential'"

else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_flags="$tmp_flags --with-blas='$(list -LD-rp-lib $la)'"
    tmp_flags="$tmp_flags --with-lapack='$(list -LD-rp-lib $la)'"

fi

pack_cmd "PETSC_DIR=$(pack_get -prefix petsc-d) CC=$MPICC CXX=$MPICXX FC=$MPIFC ../configure" \
	 "--with-metis --with-petsc" \
	 "--enable-mpi $tmp_flags" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make test 2>&1 > p4est.test"
pack_cmd "make install"
pack_store p4est.test


