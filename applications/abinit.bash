add_package http://ftp.abinit.org/abinit-7.4.3.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --host-reject ntch-l

pack_set --module-opt "--lua-family abinit"

pack_set --install-query $(pack_get --install-prefix)/bin/abinit

pack_set --module-requirement openmpi
pack_set --module-requirement atompaw
pack_set --module-requirement etsf_io
pack_set --module-requirement wannier90
pack_set --module-requirement fftw-3

tmp_openmp=
tmp_lib=
tmp=
if $(is_c gnu) ; then
    tmp_openmp="FCFLAGS_OPENMP='-fopenmp' LIBS='-fopenmp'"
    tmp="--enable-openmp"
    pack_set --module-requirement scalapack    
    if [ $(pack_installed atlas) -eq 1 ]; then
	tmp="$tmp --with-linalg-incs='$(list --INCDIRS atlas)'"
	tmp="$tmp --with-linalg-libs='$(list --LDFLAGS --Wlrpath atlas scalapack) -lscalapack -llapack_atlas -lf77blas -lcblas -latlas'"
	tmp_lib="$(list --LDFLAGS --Wlrpath atlas) -lscalapack -llapack_atlas -lf77blas -lcblas -latlas"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp="$tmp --with-linalg-incs='$(list --INCDIRS blas lapack)'"
	tmp="$tmp --with-linalg-libs='$(list --LDFLAGS --Wlrpath blas lapack scalapack) -lscalapack -llapack -lblas'"
	tmp_lib="$(list --LDFLAGS --Wlrpath blas lapack scalapack) -lscalapack -llapack -lblas"
    fi

elif $(is_c intel) ; then
    tmp_openmp="FCFLAGS_OPENMP='-fopenmp' LIBS='-openmp'"
    tmp="--enable-openmp"
    tmp="$tmp --with-linalg-libs='$MKL_LIB $INTEL_LIB -mkl=parallel'"
    tmp_lib="$MKL_LIB -mkl=parallel"

else
    doerr abinit "Could not determine compiler..."

fi

dft_flavor=atompaw+wannier90
if [ $(vrs_cmp $(pack_get --version libxc) 2.0.2) -ge 0 ]; then
    pack_set --module-requirement libxc
    # The version is recent enough to use the installed library
    dft_flavor="$dft_flavor+libxc"
    tmp="$tmp --with-libxc-incs='$(list --INCDIRS libxc)'"
    tmp="$tmp --with-libxc-libs='$(list --LDFLAGS --Wlrpath libxc) -lxc'"
fi
if [ $(vrs_cmp $(pack_get --version bigdft) 1.7) -lt 0 ]; then
    pack_set --module-requirement bigdft
    # The version is old enough to use the installed library
    dft_flavor="$dft_flavor+bigdft"
    tmp="$tmp --with-bigdft-incs='$(list --INCDIRS bigdft)'"
    tmp="$tmp --with-bigdft-libs='$(list --LDFLAGS --Wlrpath bigdft) -lbigdft-1'"
fi

pack_set --command "$tmp_openmp CC='$MPICC' FC='$MPIFC' CXX='$MPICXX' ../configure" \
    --command-flag "--enable-64bit-flags" \
    --command-flag "--enable-lotf" \
    --command-flag "--enable-mpi-inplace" \
    --command-flag "--enable-mpi --enable-mpi-io" \
    --command-flag "--with-dft-flavor=$dft_flavor" \
    --command-flag "--with-atompaw-bins=$(pack_get --install-prefix atompaw)/bin" \
    --command-flag "--with-atompaw-incs='$(list --INCDIRS atompaw )'" \
    --command-flag "--with-atompaw-libs='$(list --LDFLAGS --Wlrpath atompaw) -latompaw $tmp_lib'" \
    --command-flag "--with-etsf-io-incs='$(list --INCDIRS etsf_io)'" \
    --command-flag "--with-etsf-io-libs='$(list --LDFLAGS --Wlrpath etsf_io) -letsf_io -letsf_io_utils -letsf_io_low_level'" \
    --command-flag "--with-netcdf-incs='$(list --INCDIRS netcdf-serial)'" \
    --command-flag "--with-netcdf-libs='$(list --LDFLAGS --Wlrpath netcdf-serial) -lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--with-fft-flavor=fftw3-mpi" \
    --command-flag "--with-fft-incs='$(list --INCDIRS fftw-3)'" \
    --command-flag "--with-fft-libs='$(list --LDFLAGS --Wlrpath fftw-3) -lfftw3f_omp -lfftw3f_mpi -lfftw3f -lfftw3_omp -lfftw3_mpi -lfftw3'" \
    --command-flag "--with-trio-flavor=etsf_io+netcdf" \
    --command-flag "--with-wannier90-bins=$(pack_get --install-prefix wannier90)/bin" \
    --command-flag "--with-wannier90-incs='$(list --INCDIRS wannier90)'" \
    --command-flag "--with-wannier90-libs='$(list --LDFLAGS --Wlrpath wannier90) -lwannier'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "$tmp"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
