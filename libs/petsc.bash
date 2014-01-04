add_package --package petsc \
    --directory petsc-3.4.3 \
    http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.4.3.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libpetsc.so

pack_set --module-requirement openmpi \
    --module-requirement parmetis \
    --module-requirement fftw-3 \
    --module-requirement hdf5

tmp=''
if $(is_c intel) ; then
    tmp="$tmp --with-blas-lapack-dir=$MKL_PATH/lib/intel64"
   # tmp="$tmp --with-blas-lib='-lmkl_blas95_lp64'"
   # tmp="$tmp --with-lapack-lib='-lmkl_lapack95_lp64'"
    tmp="$tmp --with-scalapack=1"
    #tmp="$tmp --with-scalapack-dir=$MKL_PATH/lib/intel64" 
    tmp="$tmp --with-scalapack-lib='-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
    tmp="$tmp --with-scalapack-include=$MKL_PATH/include"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="$tmp --with-blas-lib='-lf77blas -lcblas -latlas'"
	tmp="$tmp --with-lapack-lib='-llapack_atlas'"
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp="$tmp --with-blas-lib=-lblas"
	tmp="$tmp --with-lapack-lib=-llapack"
    fi
    pack_set --module-requirement scalapack
    tmp="$tmp --with-scalapack-dir=$(pack_get --install-prefix scalapack)"

else
    doerr petsc "Could not determine compiler"

fi

tmp_ld="$(list --Wlrpath --LDFLAGS $(pack_get --module-requirement))"

pack_set --command "./configure PETSC_DIR=\$(pwd)" \
    --command-flag "CC='$MPICC' CFLAGS='$CFLAGS $tmp_ld'" \
    --command-flag "CXX='$MPICXX' CXXFLAGS='$CFLAGS $tmp_ld'" \
    --command-flag "FC='$MPIF90' FCFLAGS='$FCFLAGS $tmp_ld'" \
    --command-flag "F77='$MPIF77' FFLAGS='$FFLAGS $tmp_ld'" \
    --command-flag "LDFLAGS='$tmp_ld'" \
    --command-flag "LIBS='$tmp_ld'" \
    --command-flag "AR=$AR" \
    --command-flag "RANLIB=ranlib" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-fortran-interfaces=1" \
    --command-flag "--with-pic=1 $tmp" \
    --command-flag "--with-parmetis=1" \
    --command-flag "--with-parmetis-dir=$(pack_get --install-prefix parmetis)" \
    --command-flag "--with-metis=1" \
    --command-flag "--with-metis-dir=$(pack_get --install-prefix parmetis)" \
    --command-flag "--with-hwloc=1" \
    --command-flag "--with-hwloc-dir=$(pack_get --install-prefix hwloc)" \
    --command-flag "--with-hdf5=1" \
    --command-flag "--with-hdf5-dir=$(pack_get --install-prefix hdf5)" \
    --command-flag "--with-fftw=1" \
    --command-flag "--with-fftw-dir=$(pack_get --install-prefix fftw-3)"

#    --command-flag "--with-mumps=1" \
#    --command-flag "--with-mumps-lib='$(list --LDFLAGS --Wlrpath mumps) -lzmumps -ldmumps -lmumps_common -lpord'" \
#--command-flag "--with-mumps-include=$(pack_get --install-prefix mumps)/include"

#    --command-flag "--with-superlu_dist=1" \
#    --command-flag "--with-superlu_dist-dir=$(pack_get --install-prefix superlu)" \

#    --command-flag "--with-cholmod=1" \
#    --command-flag "--with-cholmod-dir=$(pack_get --install-prefix cholmod)"
#    --command-flag "--with-umfpack=1" \
#    --command-flag "--with-umfpack-dir=$(pack_get --install-prefix umfpack) $tmp"
#    --command-flag "--with-scalar-type=complex" \ #error on hwloc
#    --command-flag "--with-netcdf=1" \
#    --command-flag "--with-netcdf-dir=$(pack_get --install-prefix netcdf)" \


# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

# This tests the installation (i.e. linking)
pack_set --command "make PETSC_DIR=$(pack_get --install-prefix) test"

pack_set --module-opt "--set-ENV PETSC_DIR=$(pack_get --install-prefix)"
