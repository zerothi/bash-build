v=3.6.3
add_package --package petsc \
	    --directory petsc-$v \
	    http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libpetsc.so
pack_set --lib -lpetsc

pack_set $(list --prefix '--mod-req ' parmetis fftw-mpi-3 hdf5)

tmp=''
if $(is_c intel) ; then
    tmp="$tmp --with-blas-lapack-dir=$MKL_PATH/lib/intel64"
    # tmp="$tmp --with-blas-lib='-lmkl_blas95_lp64'"
    # tmp="$tmp --with-lapack-lib='-lmkl_lapack95_lp64'"
    tmp="$tmp --with-scalapack=1"
    #tmp="$tmp --with-scalapack-dir=$MKL_PATH/lib/intel64" 
    tmp="$tmp --with-scalapack-lib='-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
    tmp="$tmp --with-scalapack-include=$MKL_PATH/include"

else
    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="--with-lapack-lib='$(pack_get -lib $la)' --with-blas-lib='$(pack_get -lib $la)'"
    tmp="$tmp --with-scalapack-dir=$(pack_get --prefix scalapack)"
fi

tmp_ld="$(list --LD-rp $(pack_get --mod-req))"

pack_cmd "./configure PETSC_DIR=\$(pwd)" \
	  "CC='$MPICC' CFLAGS='$CFLAGS $tmp_ld'" \
	  "CXX='$MPICXX' CXXFLAGS='$CFLAGS $tmp_ld'" \
	  "FC='$MPIF90' FCFLAGS='$FCFLAGS $tmp_ld'" \
	  "F77='$MPIF77' FFLAGS='$FFLAGS $tmp_ld'" \
	  "F90='$MPIF90'" \
	  "LDFLAGS='$tmp_ld'" \
	  "LIBS='$tmp_ld'" \
	  "AR=ar" \
	  "RANLIB=ranlib" \
	  "--prefix=$(pack_get --prefix)" \
	  "--with-fortran-interfaces=1" \
	  "--with-pic=1 $tmp" \
	  "--with-parmetis=1" \
	  "--with-parmetis-dir=$(pack_get --prefix parmetis)" \
	  "--with-metis=1" \
	  "--with-metis-dir=$(pack_get --prefix parmetis)" \
	  "--with-hwloc=1" \
	  "--with-hwloc-dir=$(pack_get --prefix hwloc)" \
	  "--with-hdf5=1" \
	  "--with-hdf5-dir=$(pack_get --prefix hdf5)" \
	  "--with-fftw=1" \
	  "--with-fftw-dir=$(pack_get --prefix fftw-mpi-3)"

# Just does not work
#     "--with-superlu_dist=1" \
#     "--with-superlu_dist-dir=$(pack_get --prefix superlu-dist)" \
#     "--with-superlu_dist-lib='-lsuperlu'"

# Requires ptesmumps
#     "--with-mumps=1" \
#     "--with-mumps-dir=$(pack_get --prefix mumps)" \
#     "--with-ptscotch=1" \
#     "--with-ptscotch-dir=$(pack_get --prefix scotch)"

#     "--with-netcdf=1" \
#     "--with-netcdf-dir=$(pack_get --prefix netcdf)" \
#     "--with-netcdf-libs='-lnetcdf -lpnetcdf'"

#     "--with-cholmod=1" \
#     "--with-cholmod-dir=$(pack_get --prefix cholmod)"
#     "--with-umfpack=1" \
#     "--with-umfpack-dir=$(pack_get --prefix umfpack) $tmp"
#     "--with-scalar-type=complex" \ #error on hwloc

pack_cmd "make"
pack_cmd "make install"

# This tests the installation (i.e. linking)
pack_cmd "make PETSC_DIR=$(pack_get --prefix) PETSC_ARCH= test > tmp.test 2>&1"
pack_set_mv_test tmp.test


pack_set --module-opt "--set-ENV PETSC_DIR=$(pack_get --prefix)"

# Clean up the unused module
pack_cmd "rm -rf $(pack_get --LD)/modules"
