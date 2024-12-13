for v in 0.12.8
do
add_package https://github.com/libmbd/libmbd/releases/download/$v/libmbd-$v.tar.gz
pack_set -lib -lmbd

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -LD)/libmbd.a

pack_set $(list -prefix '-mod-req ' mpi)

# Create the CMAKE flags
opts=

# Add default stuff
opts="$opts --log-level=debug"
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DCMAKE_BUILD_TYPE=Release"
opts="$opts -DCMAKE_C_COMPILER='$MPICC'"
opts="$opts -DCMAKE_C_FLAGS='$CFLAGS'"
opts="$opts -DCMAKE_Fortran_COMPILER='$MPIFC'"
opts="$opts -DCMAKE_Fortran_FLAGS='$FFLAGS'"

opts="$opts -DENABLE_SCALAPACK_MPI=ON"


lapack_opts=
if $(is_c intel) ; then
  la=mkl
  opts="$opts -DSCALAPACK_LIBRARY=-mkl"
  lapack_opts="-DLAPACK_LIBRARIES=-mkl"

elif $(is_c gnu) ; then
  pack_set -module-requirement scalapack
  la=$(pack_choice -i linalg)
  pack_set -module-requirement lapack-$la
  lapack_opts="-DBLAS_LIBRARIES='$(pack_get -lib[omp] $la)'"
  lapack_opts="$lapack_opts -DLAPACK_LIBRARIES='$(pack_get -lib[omp] lapack-$la)'"
  opts="$opts -DSCALAPACK_LIBRARY='$(pack_get -lib[omp] scalapack)'"
fi

pack_cmd "cmake -B. -S.. $opts $lapack_opts"
pack_cmd "cmake --build . $(get_make_parallel) --target install"

done
