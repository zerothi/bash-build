v=5.8.2
add_package --package globalarrays \
	    https://github.com/GlobalArrays/ga/releases/download/v$v/ga-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libga.so

pack_set --module-requirement mpi

pack_set --lib -lga

if $(is_c intel) ; then
    # Here we need static blacs
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread"

else
    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib[omp] $la)"
    
fi

pack_cmd "../configure MPIFC='$MPIFC' CFLAGS='$CFLAGS' FCFLAGS='$FCFLAGS'" \
	 "--prefix $(pack_get --prefix)" \
	 "--enable-cxx" \
	 "--enable-shared=yes" \
	 "--with-mpi" \
	 "--with-blas='$tmp'" \
	 "--with-lapack='$tmp'" \
	 "--with-scalapack='$tmp'"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > ga.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store ga.test
