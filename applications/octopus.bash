v=5.0.1
add_package http://www.tddft.org/programs/octopus/download/$v/octopus-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family octopus"

pack_set --install-query $(pack_get --prefix)/bin/octopus_mpi

pack_set --module-requirement mpi
pack_set --module-requirement libxc
pack_set --module-requirement gsl
pack_set --module-requirement arpack-ng
pack_set --module-requirement etsf_io
pack_set --module-requirement fftw-mpi-3
pack_set --module-requirement bgw

tmp=
if $(is_c intel) ; then
    tmp="$tmp --with-scalapack='-lmkl_scalapack_lp64'"
    tmp="$tmp --with-blacs='-lmkl_blacs_openmpi_lp64'"
    tmp="$tmp --with-lapack='-lmkl_lapack95_lp64'"
    tmp="$tmp --with-blas='-lmkl_blas95_lp64 -mkl=parallel'"

else
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="$(list --LD-rp scalapack $la)"
    tmp="$tmp --with-scalapack='$tmp_ld -lscalapack'"
    tmp="$tmp --with-blacs='$tmp_ld -lscalapack'"
    tmp="$tmp --with-lapack='$tmp_ld $(pack_get -lib $la)'"
    tmp="$tmp --with-blas='$tmp_ld $(pack_get -lib $la)'"

fi

# The old versions had one library, the newer ones have Fortran and C divided.
tmp_xc="$(pack_get --LD libxc)/libxc.a"
if [[ $(vrs_cmp $(pack_get --version libxc) 2.2.0) -ge 0 ]]; then
    tmp_xc="$(pack_get --LD libxc)/libxcf90.a $(pack_get --LD libxc)/libxc.a"
fi
tmp="$tmp --with-berkeleygw-prefix=$(pack_get --prefix bgw)"

# Correct berkeleyGW linking
pack_cmd "sed -i -e 's:/library -l:/lib -l:g;s:/library:/include:g' ../configure"

# Do not install the serial version
if [[ 0 -eq 1 ]]; then
pack_cmd "../configure LIBS_LIBXC='$tmp_xc' LIBS='$(list --LD-rp $(pack_get --mod-req)) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lfftw3_omp -lfftw3 ' CC='$MPICC' FC='$MPIFC' CXX='$MPICXX'" \
     "--enable-openmp" \
     "--enable-utils" \
     "--with-libxc-include=$(pack_get --prefix libxc)/include" \
     "--with-etsf-io-prefix=$(pack_get --prefix etsf_io)" \
     "--with-gsl-prefix=$(pack_get --prefix gsl)" \
     "--with-netcdf-prefix=$(pack_get --prefix netcdf)" \
     "--with-arpack='$(list --LD-rp arpack-ng) -lparpack -larpack'" \
     "--prefix=$(pack_get --prefix)" \
     "$tmp"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check-short > tmp.test 2>&1 || echo NVM"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.serial

# prep for the MPI-compilation...
pack_cmd "rm -rf *"
fi

pack_cmd "../configure LIBS_LIBXC='$tmp_xc' LIBS='$(list --LD-rp $(pack_get --mod-req)) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lfftw3_mpi -lfftw3_omp -lfftw3_threads -lfftw3' CC='$MPICC' FC='$MPIFC' CXX='$MPICXX'"  \
     "--enable-mpi" \
     "--enable-openmp" \
     "--with-libxc-include=$(pack_get --prefix libxc)/include" \
     "--with-etsf-io-prefix=$(pack_get --prefix etsf_io)" \
     "--with-gsl-prefix=$(pack_get --prefix gsl)" \
     "--with-netcdf-prefix=$(pack_get --prefix netcdf)" \
     "--with-arpack='$(list --LD-rp arpack-ng) -lparpack -larpack'" \
     "--prefix=$(pack_get --prefix)" \
     "$tmp"

# Make commands
if [[ $NPROCS -gt 4 ]]; then
    pack_cmd "export OCT_TEST_MPI_NPROCS=4"
else
    pack_cmd "export OCT_TEST_MPI_NPROCS=\$NPROCS"
fi
pack_cmd "make -j $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 && echo Successfull >> tmp.test || echo Failure >> tmp.test"
pack_cmd "make install"
pack_set_mv_test tmp.test tmp.test.mpi
