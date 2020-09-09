for d_type in d z
do
v=3.13.3
add_package -package petsc-$d_type \
	    -directory petsc-$v \
	    http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-$v.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libpetsc.so
pack_set -lib -lpetsc

pack_set $(list -prefix '-mod-req ' zlib parmetis fftw-mpi hdf5 boost gen-libpng pnetcdf netcdf eigen mumps scotch suitesparse seacas)

# seacas has zoltan, exodus

# Find hwloc library
tmp_hwloc=$(pack_get -mod-req[hwloc])

if [[ $(vrs_cmp $v 3.11.2) -lt 0 ]]; then
    # Patch configuration!
    o=$(pwd_archives)/petsc-libindex.patch
    dwn_file http://www.student.dtu.dk/~nicpa/packages/petsc-libindex.patch $o
    pack_cmd "patch -p1 < $o"
fi

if [[ $(vrs_cmp $v 3.13.3) -eq 0 ]]; then
    pack_cmd "sed -i -e 's/LargeDiag_AWPM/LargeDiag_HWPM/g' src/mat/impls/aij/mpi/superlu_dist/superlu_dist.c"
fi

tmp=''
if $(is_c intel) ; then
    tmp="$tmp --with-blas-lapack-dir=$MKL_PATH/lib/intel64"
    # tmp="$tmp --with-blas-lib='-lmkl_blas95_lp64'"
    # tmp="$tmp --with-lapack-lib='-lmkl_lapack95_lp64'"
    tmp="$tmp --with-scalapack=1"
    #tmp="$tmp --with-scalapack-dir=$MKL_PATH/lib/intel64" 
    tmp="$tmp --with-scalapack-lib='-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
    tmp="$tmp --with-scalapack-include=$MKL_PATH/include"
    pack_cmd "unset AR RANLIB"

else
    pack_set -module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="--with-lapack-lib='$(pack_get -lib $la)' --with-blas-lib='$(pack_get -lib $la)'"
    tmp="$tmp --with-scalapack-dir=$(pack_get -prefix scalapack) AR=$AR RANLIB=$RANLIB"
fi

case $d_type in
    d)
	tmp_arch='real'
	pack_set -mod-req hypre
	tmp="$tmp --with-hypre=1"
	tmp="$tmp --with-hypre-dir=$(pack_get -prefix hypre)"
	pack_cmd "sed -i -e 's/\(self.maxversion\).*/\1=\\\"$(pack_get -version hypre)\\\"/' config/BuildSystem/config/packages/hypre.py"
	;;
    z)
	tmp_arch='complex'
	;;
esac

tmp_ld="$(list -LD-rp $(pack_get -mod-req))"
# We need to fix d_type such that complex also works
# Should this really be a separate package???
pack_cmd "unset F77 F90 CPPFLAGS"
pack_cmd "./configure PETSC_DIR=\$(pwd)" \
	 "PETSC_ARCH=$tmp_arch" \
	 "CC='$MPICC' CFLAGS='$CFLAGS $tmp_ld'" \
	 "CXX='$MPICXX' CXXFLAGS='$CFLAGS $tmp_ld'" \
	 "FC='$MPIF90' FCFLAGS='$FCFLAGS $tmp_ld'" \
	 "F77='$MPIF77' FFLAGS='$FFLAGS $tmp_ld'" \
	 "F90='$MPIF90'" \
	 "LDFLAGS='$tmp_ld -lmpi_cxx'" \
	 "LIBS='$tmp_ld -lmpi_cxx'" \
	 "--with-scalar-type=$tmp_arch" \
	 "--prefix=$(pack_get -prefix)" \
	 "--with-petsc-arch=$tmp_arch" \
	 "--with-fortran-bindings=1" \
	 "--with-pic=1 $tmp" \
	 "--with-openmp=1" \
	 "--with-mpi=1" \
	 "--with-gmp=1" \
	 "--with-mpfr=1" \
	 "--with-zlib=1" \
	 "--with-zlib-dir=$(pack_get -prefix zlib)" \
	 "--with-eigen=1" \
	 "--with-eigen-include=$(pack_get -prefix eigen)/include/eigen3" \
	 "--with-boost=1" \
	 "--with-boost-dir=$(pack_get -prefix boost)" \
	 "--with-libpng=1" \
	 "--with-libpng-dir=$(pack_get -prefix gen-libpng)" \
	 "--with-parmetis=1" \
	 "--with-parmetis-dir=$(pack_get -prefix parmetis)" \
	 "--with-metis=1" \
	 "--with-metis-dir=$(pack_get -prefix metis)" \
	 "--with-hwloc=1" \
	 "--with-hwloc-dir=$(pack_get -prefix $tmp_hwloc)" \
	 "--with-hdf5=1" \
	 "--with-hdf5-dir=$(pack_get -prefix hdf5)" \
	 "--with-fftw=1" \
	 "--with-fftw-dir=$(pack_get -prefix fftw-mpi)" \
	 "--with-netcdf=1" \
	 "--with-netcdf-dir=$(pack_get -prefix netcdf)" \
	 "--with-pnetcdf=1" \
	 "--with-pnetcdf-dir=$(pack_get -prefix pnetcdf)" \
	 "--with-ptscotch=1" \
	 "--with-ptscotch-dir=$(pack_get -prefix scotch)" \
	 "--with-mumps=1" \
	 "--with-mumps-dir=$(pack_get -prefix mumps)" \
	 "--with-zoltan=1" \
	 "--with-zoltan-dir=$(pack_get -prefix seacas)" \
	 "--with-exodusii=1" \
	 "--with-exodusii-dir=$(pack_get -prefix seacas)" \
	 "--with-suitesparse=1" \
	 "--with-suitesparse-dir=$(pack_get -prefix suitesparse)" \
	 "--with-superlu_dist=1" \
	 "--with-superlu_dist-dir=$(pack_get -prefix superlu-dist)"

#	 "--with-cxx-dialect=C++11" \

pack_cmd "make V=1 PETSC_DIR=\$(pwd) PETSC_ARCH=$tmp_arch all"
pack_cmd "make V=1 PETSC_DIR=\$(pwd) PETSC_ARCH=$tmp_arch install"

# This tests the installation (i.e. linking)
pack_cmd "make PETSC_DIR=$(pack_get -prefix) PETSC_ARCH= check > petsc.test 2>&1"
pack_store petsc.test
pack_store $tmp_arch/lib/petsc/conf/configure.log $tmp_arch.configure.log

pack_set -module-opt "-set-ENV PETSC_DIR=$(pack_get -prefix)"

# Clean up the unused module
pack_cmd "rm -rf $(pack_get -LD)/modules"

done
