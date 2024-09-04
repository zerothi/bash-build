v=24.06
add_package -version $v -package openmolcas \
	https://gitlab.com/Molcas/OpenMolcas/-/archive/v$v/OpenMolcas-v$v.tar.bz2

pack_set -s $MAKE_PARALLEL

#pack_set --host-reject ntch-
# --host-reject zeroth

pack_set -install-query $(pack_get -prefix)/bin/caspt2.exe

pack_set $(list -prefix '-mod-req ' mpi hdf5 globalarrays)
xc_v=6
pack_set -module-requirement libxc[$xc_v]

# Add the lua family
pack_set -module-opt "--lua-family openmolcas"

# Todo add GA
#
envs=
envs="$envs GAROOT=$(pack_get -prefix globalarrays)"
envs="$envs HDF5_DIR=$(pack_get -prefix hdf5)"
envs="$envs HDF5_ROOT=$(pack_get -prefix hdf5)"
envs="$envs HDF5_INCLUDE_DIR=$(pack_get -I hdf5)"
envs="$envs HDF5_INCLUDE_DIRS=$(pack_get -I hdf5)"
#envs="$envs HDF5_LIBRARY_DIRS=$(pack_get -L hdf5)"
opts=
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DMPI=TRUE"
opts="$opts -DOPENMP=TRUE"
opts="$opts -DIPO=TRUE"
opts="$opts -DCMAKE_BUILD_TYPE=Release"
opts="$opts -DLINALG=Manual"
opts="$opts -DHDF5=true"
opts="$opts -DHDF5_ROOT=$(pack_get -prefix hdf5)"
opts="$opts -DHDF5_DIR=$(pack_get -prefix hdf5)"
opts="$opts -DHDF5_INCLUDE_DIR=$(pack_get -I hdf5)"
opts="$opts -DHDF5_INCLUDE_DIRS=$(pack_get -I hdf5)"
opts="$opts -DGA=true"
opts="$opts -DTOOLS=true"
opts="$opts -DWFA=true"
opts="$opts -DEXTERNAL_LIBXC=$(pack_get -prefix libxc[$xc_v])"

# Check for Intel MKL or not
if $(is_c intel) ; then

    tmp_blas="-qmkl=cluster"
    tmp_lapack="$tmp_blas"
    tmp_scalapack="$tmp_blas"

elif $(is_c gnu) ; then

    pack_set -module-requirement scalapack
    tmp_scalapack="$(list -LD-rp scalapack)"
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_blas="$(list -LD-rp +$la)"
    tmp_lapack="$tmp_blas $(pack_get -lib $la)"
    tmp_scalapack="$tmp_scalapack -lscalapack $tmp_lapack $tmp_blas"

else
    doerr "$(pack_get -package)" "Could not recognize the compiler: $(get_c)"

fi
opts="$opts -DLINALG_LIBRARIES='${tmp_blas// /;};${tmp_lapack// /;};${tmp_scalapack// /;}'"

pack_cmd "$envs cmake -B_build -S. $opts"
pack_cmd "cmake --build _build $(get_make_parallel)" 
pack_cmd "cmake --build _build --target install" 
