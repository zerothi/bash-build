# requires tex-packages:
#  zapfchan ly1 tex4ht

v=1.9.3
add_package 

add_package --directory bigdft-suite https://launchpad.net/bigdft/${v:0:3}/$v/+download/bigdft-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family bigdft"

pack_set --install-query $(pack_get --prefix)/bin/bigdft

pack_set --module-requirement mpi \
    --module-requirement etsf_io \
    --module-requirement libxc

tmp=
if $(is_c intel) ; then
    tmp="--with-ext-linalg='-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential'"
    tmp="$tmp --with-ext-linalg-path='$MKL_LIB $INTEL_LIB'"

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="-lscalapack $(pack_get -lib $la)"
    tmp="$tmp --with-ext-linalg-path='$(list --LD-rp scalapack +$la)'"
    tmp="$tmp --with-ext-linalg='$tmp_ld $(pack_get -lib $la)'"

else
    doerr BigDFT "Could not determine compiler..."

fi


# There are also bindings for python
pack_cmd "module load $(list -mod-names ++python)"

if [[ $(vrs_cmp $(pack_get --version libxc) 2.2.0) -ge 0 ]]; then
    xclib="-lxcf90 -lxc"
    # Replace the -lxc is the configure script with the correct lookup!
    pack_cmd "sed -i -e 's/-lxc/$xclib/g' ../configure"
else
    xclib="-lxc"
fi

    # "--enable-bindings" \
pack_cmd "CC='$MPICC' FC='$MPIFC' F77='$MPIF77' ../configure" \
     "--disable-internal-libxc --with-openmp" \
     "--with-etsf-io" \
     "--with-etsf-io-path=$(pack_get --prefix etsf_io)" \
     "--with-netcdf-path=$(pack_get --prefix netcdf)" \
     "--with-netcdf-libs='-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
     "--with-libxc-libs='$(list --LD-rp libxc) $xclib'" \
     "--with-libxc-incs='$(list --INCDIRS libxc)'" \
     "$tmp --prefix=$(pack_get --prefix)"

pack_cmd "rm -rf doc" # don't make the documents
pack_cmd "sed -i -e 's: doc : :g' Makefile" # fix Makefile

# Make commands
pack_cmd "make $(get_make_parallel)"
# It seems like there is a bug in the check call...
#pack_cmd "make check"
pack_cmd "make install prefix=$(pack_get --prefix)"

pack_cmd "module unload $(list -mod-names ++python)"
