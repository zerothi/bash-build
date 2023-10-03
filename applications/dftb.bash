for v in 22.2 23.1
do
add_package https://github.com/dftbplus/dftbplus/releases/download/$v/dftbplus-$v.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family dftb+"

pack_set --module-requirement arpack-ng
pack_set --module-requirement mpi

pack_set --install-query $(pack_get --prefix)/bin/dftb+

opts=
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DWITH_MPI=TRUE"
opts="$opts -DWITH_SOCKETS=TRUE"
opts="$opts -DWITH_TRANSPORT=TRUE"
opts="$opts -DWITH_ARPACK=TRUE"

# Check for Intel MKL or not
if $(is_c intel) ; then
  opts="$opts -DLAPACK_LIBRARY='-qmkl=parallel'"
  opts="$opts -DSCALAPACK_LIBRARY='-qmkl=parallel'"
else

  pack_set --module-requirement scalapack
  la=lapack-$(pack_choice -i linalg)
  pack_set --module-requirement $la
  
  opts="$opts -DLAPACK_LIBRARY='$(list -LD-rp ++$la) $(pack_get -lib[omp] $la)'"
  opts="$opts -DSCALAPACK_LIBRARY='-qmkl=parallel'"
  opts="$opts -DSCALAPACK_LIBRARY='$(list -LD-rp scalapack) $(pack_get -lib[omp] scalapack)'"
fi

pack_cmd "cmake -B_build -S."
pack_cmd "cmake --build _build --target install --config Release"

done
