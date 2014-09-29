# requires tex-packages:
#  zapfchan ly1 tex4ht

v=1.7.1
add_package https://launchpad.net/bigdft/1.7/$v/+download/bigdft-$v.tar.bz2

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --host-reject ntch --host-reject zerothi

pack_set --module-opt "--lua-family bigdft"

pack_set --install-query $(pack_get --prefix)/bin/bigdft

pack_set --module-requirement openmpi \
    --module-requirement etsf_io \
    --module-requirement libxc

tmp=
if $(is_c intel) ; then
    tmp="--with-ext-linalg='-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential'"
    tmp="$tmp --with-ext-linalg-path='$MKL_LIB $INTEL_LIB'"

elif $(is_c gnu) ; then

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="--with-ext-linalg='-lscalapack -llapack -lf77blas -lcblas -latlas'"
	tmp="$tmp --with-ext-linalg-path='$(list --LDFLAGS --Wlrpath atlas)'"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp="--with-ext-linalg='-lscalapack -llapack -lopenblas'"
	tmp="$tmp --with-ext-linalg-path='$(list --LDFLAGS --Wlrpath openblas)'"
    else
	pack_set --module-requirement blas
	tmp="--with-ext-linalg='-lscalapack -llapack -lblas'"
	tmp="$tmp --with-ext-linalg-path='$(list --LDFLAGS --Wlrpath blas)'"
    fi


else
    doerr BigDFT "Could not determine compiler..."

fi

# There are also bindings for python
pack_set --command "module load $(pack_get --module-name-requirement python) $(pack_get --module-name python)"

if [ $(vrs_cmp $(pack_get --version libxc) 2.2.0) -ge 0 ]; then
    xclib="-lxcf90 -lxc"
    # Replace the -lxc is the configure script with the correct lookup!
    pack_set --command "sed -i -e 's/-lxc/$xclib/g' ../configure"
else
    xclib="-lxc"
fi

    #--command-flag "--enable-bindings" \
pack_set --command "CC='$MPICC' FC='$MPIFC' F77='$MPIF77' ../configure" \
    --command-flag "--disable-internal-libxc" \
    --command-flag "--with-etsf-io" \
    --command-flag "--with-etsf-io-path=$(pack_get --prefix etsf_io)" \
    --command-flag "--with-netcdf-path=$(pack_get --prefix netcdf)" \
    --command-flag "--with-netcdf-libs='-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    --command-flag "--with-libxc-libs='$(list --LDFLAGS --Wlrpath libxc) $xclib'" \
    --command-flag "--with-libxc-incs='$(list --INCDIRS libxc)'" \
    --command-flag "$tmp"

pack_set --command "rm -rf doc" # don't make the documents
pack_set --command "sed -i -e 's: doc : :g' Makefile" # fix Makefile

# Make commands
pack_set --command "make $(get_make_parallel)"
# It seems like there is a bug in the check call...
#pack_set --command "make check"
pack_set --command "make install prefix=$(pack_get --prefix)"

pack_set --command "module unload $(pack_get --module-name python) $(pack_get --module-name-requirement python)"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
