add_package http://download-mirror.savannah.gnu.org/releases/getfem/stable/getfem-5.3.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family getfem"

pack_set --module-requirement mpi
pack_set --module-requirement mumps

# Force the named alias
pack_set --install-query $(pack_get --prefix)/lib/libgetfem.a

tmp_libs="$(list --LD-rp ++mumps) $(pack_get --lib mumps) $(pack_get --lib parmetis)"

if $(is_c intel) ; then
    tmp_blas="$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    
elif $(is_c gnu) ; then
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_blas="$(list --LD-rp $la) $(pack_get --lib $la)"
    
fi

pack_cmd "../configure CXX=$MPICXX CC=$MPICC FC=$MPIFC LIBS='$tmp_libs $tmp_blas' --disable-openmp" \
	 "--enable-paralevel" \
	 "--enable-metis" \
	 "--enable-par-mumps" \
	 "--disable-boost" \
	 "--disable-matlab" \
	 "--disable-scilab" \
	 "--disable-python" \
	 "--with-blas='$tmp_blas'" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
