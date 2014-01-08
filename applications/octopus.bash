v=4.1.2
add_package http://www.tddft.org/programs/octopus/download/$v/octopus-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --host-reject ntch-l
pack_set --host-reject zerothi

pack_set --module-opt "--lua-family octopus"

pack_set --install-query $(pack_get --install-prefix)/bin/octopus

pack_set --module-requirement openmpi
pack_set --module-requirement libxc
pack_set --module-requirement gsl
pack_set --module-requirement arpack-ng
pack_set --module-requirement etsf_io
pack_set --module-requirement fftw-3

tmp=
if $(is_c gnu) ; then
    pack_set --module-requirement scalapack    
    tmp="$tmp --with-scalapack='$(list --LDFLAGS --Wlrpath scalapack) -lscalapack'"
    if [ $(pack_installed atlas) -eq 1 ]; then
	tmp="$tmp --with-blas='$(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas'"
	tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas'"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp="$tmp --with-blas='$(list --LDFLAGS --Wlrpath blas) -lblas'"
	tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath lapack) -llapack'"
    fi

elif $(is_c intel) ; then
    tmp="$tmp --with-blas='-mkl=cluster'"
    tmp="$tmp --with-lapack='-mkl=cluster'"
    tmp="$tmp --with-scalapack='-mkl=cluster'"

else
    doerr octopus "Could not determine compiler..."

fi

pack_set --command "LIBS='$(list --LDFLAGS --Wlrpath netcdf fftw-3) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz -lfftw3_omp -lfftw3 ' CC='$MPICC' FC='$MPIFC' CXX='$MPICXX' ../configure" \
    --command-flag "--enable-openmp" \
    --command-flag "--enable-utils" \
    --command-flag "--with-libxc-prefix=$(pack_get --install-prefix libxc)" \
    --command-flag "--with-etsf-io-prefix=$(pack_get --install-prefix etsf_io)" \
    --command-flag "--with-gsl-prefix=$(pack_get --install-prefix gsl)" \
    --command-flag "--with-netcdf-prefix=$(pack_get --install-prefix netcdf)" \
    --command-flag "--with-arpack='$(list --LDFLAGS --Wlrpath arpack-ng) -lparpack -larpack'" \
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
