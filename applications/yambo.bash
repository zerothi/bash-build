v=3.3.0-41
add_package --version $v \
    http://qe-forge.org/gf/download/frsrelease/133/433/yambo-${v//-/-rev}.tgz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

#pack_set --host-reject ntch-
# --host-reject zeroth

pack_set --install-query $(pack_get --prefix)/bin/yambo

pack_set --module-requirement openmpi --module-requirement netcdf \
    --module-requirement etsf_io --module-requirement fftw-3

# Add the lua family
pack_set --module-opt "--lua-family yambo"

tmp_blas=
tmp_lapack=
tmp_scalapack=
# Check for Intel MKL or not
if $(is_c intel) ; then

    tmp_blas="-mkl=cluster"
    tmp_lapack="$tmp_blas"
    tmp_scalapack="$tmp_blas"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp_blas="$(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas"
	tmp_lapack="$(list --LDFLAGS --Wlrpath atlas) -llapack"
    elif [ $(pack_installed openblas) -eq 1 ] ; then
	pack_set --module-requirement openblas
	tmp_blas="$(list --LDFLAGS --Wlrpath openblas) -lopenblas"
	tmp_lapack="$(list --LDFLAGS --Wlrpath openblas) -llapack"
    else
	pack_set --module-requirement blas --module-requirement lapack
	tmp_blas="$(list --LDFLAGS --Wlrpath blas) -lblas"
	tmp_lapack="$(list --LDFLAGS --Wlrpath lapack) -llapack"
    fi
    pack_set --module-requirement scalapack
    tmp_scalapack="$(list --LDFLAGS --Wlrpath scalapack) -lscalapack $tmp_lapack $tmp_blas"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

# make a copy of the IOTK-library
pack_set --command "mkdir -p my_IOTK/src"
pack_set --command "cp $(pack_get --library-path espresso)/libiotk.a my_IOTK/src/"
# make a copy of the libxc library
pack_set --command "cp $(pack_get --library-path libxc)/libxc.a lib/"


pack_set --command "./configure PFC='$MPIFC' " \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--enable-netcdf-LFS --enable-netcdf-hdf5" \
    --command-flag "--with-blas='$tmp_blas' --with-lapack='$tmp_lapack'" \
    --command-flag "--with-blacs='$tmp_scalapack'" \
    --command-flag "--with-scalapack='$tmp_scalapack'" \
    --command-flag "--with-etsf-io-include=$(pack_get --prefix etsf_io)/include" \
    --command-flag "--with-etsf-io-lib=$(pack_get --library-path etsf_io)" \
    --command-flag "--with-netcdf-include=$(pack_get --prefix netcdf)/include" \
    --command-flag "--with-netcdf-lib=$(pack_get --library-path netcdf)" \
    --command-flag "--with-netcdf-link='$(list --INCDIRS --LDFLAGS --Wlrpath netcdf pnetcdf hdf5 zlib) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--with-fftw=$(pack_get --prefix fftw-3)" \
    --command-flag "--with-iotk=\$(pwd)/my_IOTK --with-p2y=5.0"

# Fix line endings...
pack_set --command 'sed -i -e ":a;N;$!ba;s/\\\\\n/ /g" lib/slatec/.objects'

pack_set --command "make $(get_make_parallel) all"
pack_set --command "sotuhasehuh"


pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
