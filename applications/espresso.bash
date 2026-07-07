for v in 7.2 7.3.1 7.4.1 7.5 ; do

add_package -package q-espresso -version $v \
  https://gitlab.com/QEF/q-e/-/archive/qe-$v/q-e-qe-$v.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/lib/libqe_epw.a

pack_set -module-opt "-lua-family q-espresso"

pack_set $(list -prefix '-mod-req ' mpi hdf5 fftw libxc wannier90 elpa libmbd)

if [ -z "$FLAG_OMP" ]; then
  doerr q-espresso "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Fix the gcc-12 bug that limits the tree-vectorizer-loop
pack_cmd "echo 'target_compile_options(qe_devxlib PRIVATE -fno-tree-vectorize)' >> ../external/devxlib.cmake"

# Create the CMAKE flags
opts=

# Add default stuff
opts="$opts --log-level=debug"
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
opts="$opts -DCMAKE_BUILD_TYPE=Release"
opts="$opts -DCMAKE_VERBOSE_MAKEFILE=on"
opts="$opts -DCMAKE_C_COMPILER='$MPICC'"
opts="$opts -DCMAKE_C_FLAGS='$CFLAGS'"
opts="$opts -DCMAKE_Fortran_COMPILER='$MPIFC'"
opts="$opts -DCMAKE_Fortran_FLAGS='$FFLAGS'"

# Environ is something that enables continuum embedding calculations
opts="$opts -DQE_ENABLE_ENVIRON=off"
opts="$opts -DQE_ENABLE_MPI=on"
opts="$opts -DQE_ENABLE_MPI_INPLACE=on"
opts="$opts -DQE_ENABLE_OPENMP=on"
opts="$opts -DQE_ENABLE_SCALAPACK=on"
opts="$opts -DQE_ENABLE_ELPA=on"
opts="$opts -DQE_MBD_INTERNAL=OFF"
opts="$opts -DMBD_ROOT=$(pack_get -prefix libmbd)"
opts="$opts -DELPA_Fortran_MODS_DIR=$(pack_get -I elpa)/elpa"
opts="$opts -DQE_ENABLE_LIBXC=on"
opts="$opts -DLIBXC_ROOT=$(pack_get -prefix libxc)"
opts="$opts -DQE_ENABLE_HDF5=on"
opts="$opts -DHDF5_ROOT=$(pack_get -prefix hdf5)"
opts="$opts -DQE_ENABLE_FOX=on"

opts="$opts -DQE_FFTW_VENDOR=FFTW3"
opts="$opts -DFFTW3_ROOT=$(pack_get -prefix fftw)"

#opts="$opts -DQE_ENABLE_WANNIER90=on"
opts="$opts -DWANNIER90_ROOT=$(pack_get -prefix wannier90)"

lapack_opts=
if $(is_c intel) ; then
  qe_la=mkl
  opts="$opts -DSCALAPACK_LIBRARY=-mkl=cluster"
  lapack_opts="-DLAPACK_LIBRARIES=-mkl=cluster"

elif $(is_c gnu) ; then
  pack_set -module-requirement scalapack
  qe_la=$(pack_choice -i linalg)
  la=lapack-$qe_la
  pack_set -module-requirement $la
  opts="$opts -DSCALAPACK_LIBRARY='$(pack_get -lib scalapack)'"
  lapack_opts="-DBLAS_LIBRARIES='$(pack_get -lib[omp] $qe_la)'"
  lapack_opts="$lapack_opts -DLAPACK_LIBRARIES='$(pack_get -lib[omp] $la)'"
fi

pack_cmd "cmake -B. -S.. $opts $lapack_opts"
pack_cmd "cmake --build . $(get_make_parallel) --target install"

done

