v=9.4.2
add_package https://github.com/dealii/dealii/releases/download/v$v/dealii-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set $(list -prefix '-mod-req ' boost mpi gsl hdf5 metis petsc-d slepc-d p4est arpack-ng suitesparse)

pack_set -install-query $(pack_get -LD)/libdeal_II.so
pack_set -lib -ldealii

# Build-options
tmp_flags=
tmp_flags="$tmp_flags -DZLIB_DIR=$(pack_get -prefix zlib)"
tmp_flags="$tmp_flags -DUMFPACK_DIR=$(pack_get -prefix suitesparse) -DDEAL_II_WITH_UMFPACK=ON"
tmp_flags="$tmp_flags -DARPACK_DIR=$(pack_get -prefix arpack-ng) -DDEAL_II_WITH_ARPACK=ON"
tmp_flags="$tmp_flags -DHDF5_DIR=$(pack_get -prefix hdf5) -DDEAL_II_WITH_HDF5=ON"
tmp_flags="$tmp_flags -DGSL_DIR=$(pack_get -prefix gsl) -DDEAL_II_WITH_GSL=ON"
tmp_flags="$tmp_flags -DMETIS_DIR=$(pack_get -prefix metis) -DDEAL_II_WITH_METIS=ON"
tmp_flags="$tmp_flags -DPETSC_DIR=$(pack_get -prefix petsc-d) -DDEAL_II_WITH_PETSC=ON"
tmp_flags="$tmp_flags -DSLEPC_DIR=$(pack_get -prefix slepc-d) -DDEAL_II_WITH_SLEPC=ON"
tmp_flags="$tmp_flags -DBOOST_DIR=$(pack_get -prefix boost) -DDEAL_II_WITH_BOOST=ON"
tmp_flags="$tmp_flags -DP4EST_DIR=$(pack_get -prefix p4est) -DDEAL_II_WITH_P4EST=ON"
tmp_flags="$tmp_flags -DDEAL_II_WITH_MPI=ON"

tmp_flags="$tmp_flags -DDEAL_II_WITH_TRILINOS=OFF"
tmp_flags="$tmp_flags -DCMAKE_BUILD_TYPE=Release"
tmp_flags="$tmp_flags -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"

if $(is_c intel) ; then
    tmp_flags="$tmp_flags -DLAPACK_FOUND=true -DLAPACK_LIBRARIES='$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential'"
#    tmp_flags="$tmp_flags -DBLAS_FOUND=true -DBLAS_LIBRARIES='$MKL_LIB -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential'"
    tmp_flags="$tmp_flags -DSCALAPACK_FOUND=true -DSCALAPACK_LIBRARIES='$MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"

else

    pack_set -module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    # We are using C compilers and thus require gfortran library
    tmp_flags="$tmp_flags -DLAPACK_FOUND=true -DLAPACK_LIBRARIES='$(list -LD-rp-lib +$la) -lgfortran -lm'"
#    tmp_flags="$tmp_flags -DBLAS_FOUND=true -DBLAS_LIBRARIES='$(list -LD-rp-lib +$la) -lgfortran -lm'"
    tmp_flags="$tmp_flags -DSCALAPACK_FOUND=true -DSCALAPACK_LIBRARIES='$(list -LD-rp-lib scalapack)'"

fi

pack_cmd "CC=$MPICC CXX=$MPICXX CXXFLAGS='$CXXFLAGS -std=c++14' FC=$MPIFC cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) .. $tmp_flags"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test 2>&1 > dealii.test || echo forced" 
pack_cmd "make install"
pack_store dealii.test


