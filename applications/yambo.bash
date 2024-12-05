v=5.2.4
add_package --version $v \
	-archive yambo-$v.tar.gz \
	https://github.com/yambo-code/yambo/archive/refs/tags/$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/yambo

pack_set $(list -prefix '-mod-req ' mpi hdf5 netcdf libxc fftw)

# Add the lua family
pack_set --module-opt "--lua-family yambo"

pack_cmd "mkdir -p $(pack_get -prefix)"

tmp="$(list -LD-rp hdf5 netcdf libxc fftw)"
tmp_blas=
tmp_lapack=
tmp_scalapack=
# Check for Intel MKL or not
if $(is_c intel) ; then

    tmp_blas="-qmkl=cluster"
    tmp_lapack="$tmp_blas"
    tmp_scalapack="$tmp_blas"

elif $(is_c gnu) ; then

    pack_set --module-requirement scalapack
    tmp_scalapack="$(list -LD-rp scalapack)"
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_blas="$(list -LD-rp +$la)"
    tmp_lapack="$tmp_blas $(pack_get -lib $la)"
    tmp_scalapack="$tmp_scalapack -lscalapack $tmp_lapack $tmp_blas"

else
    doerr "$(pack_get -package)" "Could not recognize the compiler: $(get_c)"

fi

pack_cmd "BLAS_LIBS='$tmp $tmp_blas' CPP='$CC -E -P' FPP='$FC -cpp -E -P'" ./configure \
    --prefix=$(pack_get -prefix) \
    "--with-blas-libs='$tmp_blas'" \
    "--with-lapack-libs='$tmp_lapack'" \
    "--with-blacs-libs='$tmp_scalapack'" \
    "--with-scalapack-libs='$tmp_scalapack'" \
    --enable-uspp \
    --enable-open-mp \
    --enable-mpi \
    --enable-par-linalg \
    --enable-hdf5-par-io \
    --with-hdf5-path=$(pack_get -prefix hdf5) \
    "--with-hdf5-libs='$(list -LD-rp hdf5) $(pack_get -lib[fortran] hdf5)'" \
    --enable-netcdf-output \
    --with-netcdf-path=$(pack_get -prefix netcdf) \
    "--with-netcdf-libs='$(list -LD-rp netcdf) $(pack_get -lib netcdf)'" \
    --with-netcdff-path=$(pack_get -prefix netcdf) \
    "--with-netcdff-libs='$(list -LD-rp netcdf) $(pack_get -lib[fortran] netcdf)'" \
    --with-libxc-path=$(pack_get -prefix libxc) \
    "--with-libxc-libs='$(list -LD-rp libxc) $(pack_get -lib[f03] libxc)'" \
    --with-fft-path=$(pack_get -prefix fftw) \
    --enable-3d-fft

# Correct setup file
pack_cmd "sed -i -e 's:lnetcdf[ ]*=:lnetcdf = $(list -LD-rp netcdf):' config/setup"
pack_cmd "sed -i -e 's:lnetcdff[ ]*=:lnetcdff = $(list -LD-rp netcdf):' config/setup"
pack_cmd "sed -i -e 's:lhdf5[ ]*=:lhdf5 = $(list -LD-rp hdf5):' config/setup"

# Remove a2y+c2y from ALL
pack_cmd "sed -i -e 's: a2y : :' config/mk/global/targets.mk"
pack_cmd "sed -i -e 's: c2y : :' config/mk/global/targets.mk"
pack_cmd "make $(get_make_parallel) all"

# check that version works (basically check that it links correctly)
pack_cmd "$(pack_get -prefix)/bin/yambo --version"
