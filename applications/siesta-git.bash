pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set -module-opt "--lua-family siesta"

pack_set -install-query /always/install/this/module

pack_set $(list -prefix '-mod-req ' mpi netcdf libgridxc libpsml elpa)

prefix=$(pack_get -prefix)
opts="-DCMAKE_BUILD_TYPE=Release"
lapack_opts=

if $(is_c intel) ; then
  siesta_la=mkl

elif $(is_c gnu) ; then
    
  pack_set -module-requirement scalapack
  siesta_la=$(pack_choice -i linalg)
  la=lapack-$siesta_la
  pack_set -module-requirement $la
  opts="$opts -DSCALAPACK_LIBRARY='$(pack_get -lib scalapack)'"
  lapack_opts="-DLAPACK_LIBRARY='$(pack_get -lib $la)'"

fi

if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_set -module-requirement flook
    opts="$opts -DSIESTA_WITH_FLOOK=on"
    opts="$opts -DWITH_FLOOK=on"
fi

opts="$opts --log-level=debug"
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DSIESTA_WITH_NCDF=on -DSIESTA_WITH_MPI=on"
opts="$opts -DWITH_NCDF=on -DWITH_MPI=on"
opts="$opts -DSIESTA_WITH_LIBXC=on"
opts="$opts -DWITH_LIBXC=on"

if $(is_c gnu) ; then
  lapack_opts="-DLAPACK_LIBRARY='$(pack_get -lib[omp] $la)'"
fi
    
pack_cmd "cmake -Bbuild-tmp-omp -S. $opts -DWITH_OPENMP=true -DSIESTA_WITH_OPENMP=true -DSIESTA_EXECUTABLE_SUFFIX=_omp $lapack_opts"
pack_cmd "cmake --build build-tmp-omp $(get_make_parallel) --target install"

if $(is_c gnu) ; then
  lapack_opts="-DLAPACK_LIBRARY='$(pack_get -lib[omp] $la)'"
fi

pack_cmd "cmake -Bbuild-tmp -S. $opts $lapack_opts"
pack_cmd "cmake --build build-tmp $(get_make_parallel) --target install"


