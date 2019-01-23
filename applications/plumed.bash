add_package https://github.com/plumed/plumed2/releases/download/v2.5.0/plumed-2.5.0.tgz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/plumed-patch

pack_set --module-requirement mpi --module-requirement fftw

pack_cmd "./configure --prefix=$(pack_get --prefix) --enable-mpi --enable-fftw --enable-rpath=yes"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
