v=2.16.0
add_package -archive hypre-$v.tar.gz \
	    https://github.com/hypre-space/hypre/archive/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_TOOLS

pack_set -install-query $(pack_get -LD)/libHYPRE.a
pack_set $(list -prefix ' -mod-req ' mpi superlu)

tmp_flags="--with-openmp --with-superlu-include=$(pack_get -prefix superlu)/include"
if $(is_c intel) ; then

    tmp_flags="$tmp_flags --with-blas-lib='$MKL_LIB -lmkl_blas95_lp64 -mkl=parallel'"
    tmp_flags="$tmp_flags --with-lapack-lib='$MKL_LIB -lmkl_lapack95_lp64 -mkl=parallel'"

else
    
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_flags="$tmp_flags --with-blas-lib='$(list -LD-rp +$la) $(pack_get -lib[omp] $la)'"
    tmp_flags="$tmp_flags --with-lapack-lib='$(list -LD-rp +$la) $(pack_get -lib[omp] $la)'"

fi

pack_cmd "cd src"
pack_cmd "AR='$AR -rcu' CC='$MPICC' CXX='$MPICXX' FC='$MPIFC' ./configure --with-superlu --with-mpi $tmp_flags --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
