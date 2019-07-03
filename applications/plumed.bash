v=2.5.1
add_package https://github.com/plumed/plumed2/releases/download/v$v/plumed-$v.tgz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/plumed-patch

pack_set $(list -prefix '-mod-req ' mpi fftw gsl boost)

tmp=
if $(is_c intel) ; then
    tmp="$MKL_LIB -mkl=parallel"
    
else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$(list -LD-rp-lib[omp] +$la)"

fi

pack_cmd "LIBS='$tmp' FC=$MPIFC CC=$MPICC CXX=$MPICXX ./configure" \
	 "--prefix=$(pack_get -prefix)" \
	 "--enable-mpi --enable-fftw --enable-gsl --enable-boost_graph" \
	 "--enable-rpath=yes"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
