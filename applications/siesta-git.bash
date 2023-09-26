pack_set -s $MAKE_PARALLEL

# Add the lua family
pack_set -module-opt "--lua-family siesta"

pack_set -install-query /always/install/this/module

pack_set $(list -prefix '-mod-req ' mpi netcdf libgridxc libpsml elpa)

siesta_la=mkl
prefix=$(pack_get -prefix)
opts=

if $(is_c intel) ; then
  noop

elif $(is_c gnu) ; then
    
  pack_set -module-requirement scalapack
  siesta_la=$(pack_choice -i linalg)
  la=lapack-$siesta_la
  pack_set -module-requirement $la
  opts="$opts -DSCALAPACK_LIBRARY='$(pack_get -lib scalapack)'"
  opts="$opts -DLAPACK_LIBRARY='$(pack_get -lib $la)'"

fi

# Initial setup for new trunk with transiesta
if [[ $(pack_installed flook) -eq 1 ]]; then
    pack_set -module-requirement flook
    opts="$opts -DWITH_FLOOK=on"
fi

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_cmd 'sed -i -e "s:__FILE__:Fstack.T90:g" Src/Fstack.T90'

opts="$opts --log-level=debug"
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DWITH_NCDF=on -DWITH_MPI=on"
opts="$opts -DWITH_LIBXC=on"

pack_cmd "cmake -Bbuild-tmp -S. $opts"
pack_cmd "cmake --build build-tmp $(get_make_parallel)"
pack_cmd "cmake --build build-tmp --target install"
