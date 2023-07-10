v=1.2.0
add_package -package pexsi-dev -version 0 \
       https://bitbucket.org/berkeleylab/pexsi.git

pack_set -s $IS_MODULE
pack_set -install-query $(pack_get -LD)/libpexsi_linux.a
pack_set -lib -lpexsi_linux

superlu_v=7.2

pack_set $(list -p '-mod-req ' mpi parmetis scotch superlu-dist[$superlu_v] sympack)
pack_set -build-mod-req cmake

# Prepare the make file
tmp=
tmp="$tmp -DPEXSI_ENABLE_SYMPACK=on"
tmp="$tmp -DPEXSI_ENABLE_FORTRAN=on"
tmp="$tmp -DPEXSI_ENABLE_OPENMP=on"
tmp="$tmp -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
tmp="$tmp -DMETIS_PREFIX='$(pack_get -prefix parmetis)'"
tmp="$tmp -DMETIS_LIBRARIES='$(list -LD-rp parmetis) $(pack_get -lib parmetis)'"
tmp="$tmp -DParMETIS_PREFIX='$(pack_get -prefix parmetis)'"
tmp="$tmp -DParMETIS_LIBRARIES='$(list -LD-rp parmetis) $(pack_get -lib parmetis)'"
tmp="$tmp -DSCOTCH_PREFIX='$(pack_get -prefix scotch)'"
tmp="$tmp -DSCOTCH_LIBRARIES='$(list -LD-rp scotch) $(pack_get -lib scotch)'"
tmp="$tmp -DSuperLU_DIST_PREFIX='$(pack_get -prefix superlu-dist[$superlu_v])'"
tmp="$tmp -DSuperLU_DIST_LIBRARIES='$(list -LD-rp superlu-dist[$superlu_v]) $(pack_get -lib superlu-dist[$superlu_v])'"


# Add LAPACK and BLAS libraries
if $(is_c intel) ; then

    tmp="$tmp -DBLAS_LIBRARIES='$MKL_LIB -qmkl=parallel'"
    tmp="$tmp -DLAPACK_LIBRARIES='$MKL_LIB -qmkl=parallel'"

elif $(is_c gnu) ; then
    
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$tmp -DBLAS_LIBRARIES='$(list -LD-rp +$la) $(pack_get -lib[omp] $la) -lgfortran'"
    tmp="$tmp -DLAPACK_LIBRARIES='$(list -LD-rp +$la) $(pack_get -lib[omp] $la) -lgfortran'"

else
    doerr "$(pack_get -package)" "Could not recognize the compiler: $(get_c)"

fi

pack_cmd "FC=$MPIFC CC=$MPICC CXX=$MPICXX CFLAGS='$CFLAGS $FLAG_OMP' \
	CXXFLAGS='$CXXFLAGS $FLAG_OMP' cmake $tmp --debug-output -Bbuild-tmp -S."
pack_cmd "FC=$MPIFC CC=$MPICC CXX=$MPICXX CFLAGS='$CFLAGS $FLAG_OMP' \
	CXXFLAGS='$CXXFLAGS $FLAG_OMP' cmake $tmp --build build-tmp"
pack_cmd "FC=$MPIFC CC=$MPICC CXX=$MPICXX CFLAGS='$CFLAGS $FLAG_OMP' \
	CXXFLAGS='$CXXFLAGS $FLAG_OMP' cmake $tmp --build build-tmp --target install"
