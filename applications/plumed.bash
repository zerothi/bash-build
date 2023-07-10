v=2.7.3
add_package https://github.com/plumed/plumed2/releases/download/v$v/plumed-$v.tgz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/plumed-patch

# PLUMED fails to fix the runtime path for the plumed executable
pack_set --module-opt "-ld-library-path"

pack_set $(list -prefix '-mod-req ' mpi fftw gsl boost)

tmp="$(list -LD-rp-lib[omp] gsl fftw)"
if $(is_c intel) ; then
    tmp="$tmp $MKL_LIB -qmkl=parallel"
    
else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$(list -LD-rp-lib[omp] +$la) -lgfortran"
fi

pack_cmd "LIBS='$tmp' FC='$MPIFC' CC='$MPICC' CXX='$MPICXX' ./configure" \
	 "--prefix=$(pack_get -prefix)" \
	 "--enable-mpi --enable-fftw --enable-gsl --enable-boost_graph" \
	 "--enable-rpath=yes"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
