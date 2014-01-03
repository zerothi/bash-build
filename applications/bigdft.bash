# requires tex-packages:
#  zapfchan ly1 tex4ht

v=1.7.1
add_package https://launchpad.net/bigdft/1.7/$v/+download/bigdft-$v.tar.bz2

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --host-reject ntch

pack_set --module-opt "--lua-family bigdft"

pack_set --install-query $(pack_get --install-prefix)/bin/bigdft

pack_set --module-requirement openmpi \
    --module-requirement etsf_io

tmp=
if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --module-requirement scalapack
	tmp="--with-ext-linalg='-lscalapack -llapack_atlas -lf77blas -lcblas -latlas'"
	tmp="$tmp --with-ext-linalg-path='$(list --LDFLAGS --Wlrpath atlas scalapack)'"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	pack_set --module-requirement scalapack
	tmp="--with-ext-linalg='-lscalapack -llapack -lblas'"
	tmp="$tmp --with-ext-linalg-path='$(list --LDFLAGS --Wlrpath blas lapack scalapack)'"
    fi

elif $(is_c intel) ; then
    tmp="--with-ext-linalg='-lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel'"
    tmp="$tmp --with-ext-linalg-path='$MKL_LIB $INTEL_LIB'"

fi

# There are also bindings for python
pack_set --command "module load $(pack_get --module-name-requirement python) $(pack_get --module-name python)"

    #--command-flag "--enable-bindings" \
pack_set --command "CC='$MPICC' FC='$MPIFC' F77='$MPIF77' ../configure" \
    --command-flag "--disable-internal-libxc" \
    --command-flag "--with-etsf-io" \
    --command-flag "--with-etsf-io-path=$(pack_get --install-prefix etsf_io)" \
    --command-flag "--with-netcdf-libs='-lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--with-libxc-libs='$(list --LDFLAGS --Wlrpath libxc) -lxc'" \
    --command-flag "--with-libxc-incs='$(list --INCDIRS libxc)'" \
    --command-flag "$tmp"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install prefix=$(pack_get --install-prefix)"

pack_set --command "module unload $(pack_get --module-name python) $(pack_get --module-name-requirement python)"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
