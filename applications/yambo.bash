v=3.3.0-41
add_package --version $v \
    http://qe-forge.org/gf/download/frsrelease/133/433/yambo-${v//-/-rev}.tgz

pack_set -s $MAKE_PARALLEL

#pack_set --host-reject ntch-
# --host-reject zeroth

pack_set --install-query $(pack_get --prefix)/bin/yambo

pack_set --module-requirement mpi --module-requirement netcdf \
    --module-requirement etsf_io --module-requirement fftw

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

    pack_set --module-requirement scalapack
    tmp_scalapack="$(list --LD-rp scalapack)"
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_blas="$(list --LD-rp +$la)"
    tmp_lapack="$tmp_blas $(pack_get -lib $la)"
    tmp_scalapack="$tmp_scalapack -lscalapack $tmp_lapack $tmp_blas"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

# make a copy of the IOTK-library
pack_cmd "mkdir -p my_IOTK/src"
pack_cmd "cp $(pack_get --LD espresso)/libiotk.a my_IOTK/src/"
# make a copy of the libxc library
pack_cmd "cp $(pack_get --LD libxc)/libxc.a lib/"


pack_cmd "./configure PFC='$MPIFC' " \
    "--prefix=$(pack_get --prefix)" \
    "--enable-netcdf-LFS --enable-netcdf-hdf5" \
    "--with-blas='$tmp_blas' --with-lapack='$tmp_lapack'" \
    "--with-blacs='$tmp_scalapack'" \
    "--with-scalapack='$tmp_scalapack'" \
    "--with-etsf-io-include=$(pack_get --prefix etsf_io)/include" \
    "--with-etsf-io-lib=$(pack_get --LD etsf_io)" \
    "--with-netcdf-include=$(pack_get --prefix netcdf)/include" \
    "--with-netcdf-lib=$(pack_get --LD netcdf)" \
    "--with-netcdf-link='$(list --INCDIRS --LD-rp +netcdf) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz'" \
    "--with-fftw=$(pack_get --prefix fftw)" \
    "--with-iotk=\$(pwd)/my_IOTK --with-p2y=5.0"

# Fix line endings...
pack_cmd 'sed -i -e ":a;N;$!ba;s/\\\\\n/ /g" lib/slatec/.objects'

pack_cmd "make $(get_make_parallel) all"
pack_cmd "sotuhasehuh"
