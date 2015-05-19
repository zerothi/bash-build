v=4.1.2
add_package http://www.tddft.org/programs/octopus/download/$v/octopus-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --host-reject ntch
pack_set --host-reject zerothi

pack_set --module-opt "--lua-family octopus"

pack_set --install-query $(pack_get --prefix)/bin/octopus_mpi

pack_set --module-requirement mpi
pack_set --module-requirement libxc
pack_set --module-requirement gsl
pack_set --module-requirement arpack-ng
pack_set --module-requirement etsf_io
pack_set --module-requirement fftw-3

tmp=
if $(is_c intel) ; then
    tmp="$tmp --with-blacs='-lmkl_blacs_openmpi_lp64'"
    tmp="$tmp --with-blas='-lmkl_blas95_lp64 -mkl=parallel'"
    tmp="$tmp --with-lapack='-lmkl_lapack95_lp64'"
    tmp="$tmp --with-scalapack='-lmkl_scalapack_lp64'"

else
    
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LDFLAGS --Wlrpath $la)"
	    tmp="$tmp --with-scalapack='$tmp_ld -lscalapack'"
	    tmp="$tmp --with-lapack='$tmp_ld -llapack'"
	    if [ "x$la" == "xatlas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lf77blas -lcblas -latlas'"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lopenblas'"
	    elif [ "x$la" == "xblas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lblas'"
	    fi
	    break
	fi
    done

fi

# The old versions had one library, the newer ones have Fortran and C divided.
tmp_xc="$(pack_get --LD libxc)/libxc.a"
if [ $(vrs_cmp $(pack_get --version libxc) 2.2.0) -ge 0 ]; then
    tmp_xc="$(pack_get --LD libxc)/libxcf90.a $(pack_get --LD libxc)/libxc.a"
fi

pack_set --command "../configure LIBS_LIBXC='$tmp_xc' LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --mod-req)) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lfftw3_omp -lfftw3 ' CC='$MPICC' FC='$MPIFC' CXX='$MPICXX'" \
    --command-flag "--enable-openmp" \
    --command-flag "--enable-utils" \
    --command-flag "--with-libxc-include=$(pack_get --prefix libxc)/include" \
    --command-flag "--with-etsf-io-prefix=$(pack_get --prefix etsf_io)" \
    --command-flag "--with-gsl-prefix=$(pack_get --prefix gsl)" \
    --command-flag "--with-netcdf-prefix=$(pack_get --prefix netcdf)" \
    --command-flag "--with-arpack='$(list --LDFLAGS --Wlrpath arpack-ng) -lparpack -larpack'" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "$tmp"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test tmp.test.serial

# prep for the MPI-compilation...
pack_set --command "rm -rf *"

pack_set --command "../configure LIBS_LIBXC='$tmp_xc' LIBS='$(list --LDFLAGS --Wlrpath $(pack_get --mod-req)) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lfftw3_mpi -lfftw3_omp -lfftw3_threads -lfftw3' CC='$MPICC' FC='$MPIFC' CXX='$MPICXX'"  \
    --command-flag "--enable-mpi" \
    --command-flag "--enable-openmp" \
    --command-flag "--with-libxc-include=$(pack_get --prefix libxc)/include" \
    --command-flag "--with-etsf-io-prefix=$(pack_get --prefix etsf_io)" \
    --command-flag "--with-gsl-prefix=$(pack_get --prefix gsl)" \
    --command-flag "--with-netcdf-prefix=$(pack_get --prefix netcdf)" \
    --command-flag "--with-arpack='$(list --LDFLAGS --Wlrpath arpack-ng) -lparpack -larpack'" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "$tmp"

# Make commands
if [ $NPROCS -gt 4 ]; then
pack_set --command "export OCT_TEST_MPI_NPROCS=4"
else
pack_set --command "export OCT_TEST_MPI_NPROCS=\$NPROCS"
fi
pack_set --command "make -j $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1 && echo Succesfull >> tmp.test || echo Failure >> tmp.test"
pack_set --command "make install"
pack_set_mv_test tmp.test tmp.test.mpi

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
