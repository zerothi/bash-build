add_package --package petsc-z \
    --directory petsc-3.4.3 \
    http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.4.3.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libpetsc.a

pack_set --module-requirement openmpi \
    --module-requirement parmetis \
    --module-requirement superlu \
    --module-requirement mumps \
    --module-requirement fftw[3] \
    --module-requirement cholmod \
    --module-requirement netcdf \
    --module-requirement umfpack


tmp=''
if $(is_c intel) ; then
    tmp="$tmp --with-blas-lib=-lmkl_blas95_lp64"
    tmp="$tmp --with-lapack-lib=-lmkl_lapack95_lp64"
    tmp="$tmp --with-scalapack=1"
    tmp="$tmp --with-scalapack-lib='-lmkl_blacs_openmpi_lp64 -lmkl_scalapack_lp64'"

else
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
    tmp="$tmp --with-scalapack-lib=-lscalapack"

fi

pack_set --command "./configure --prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-fortran-datatypes=1" \
    --command-flag "--with-fortran-interfaces=1" \
    --command-flag "--with-cc=$MPICC" \
    --command-flag "--with-fc=$MPIF90" \
    --command-flag "--with-scalar-type=complex" \
    --command-flag "--LIBS='$(list --Wlrpath --LDFLAGS $(pack_get --module-requirement))'" \
    --command-flag "--AR=$AR" \
    --command-flag "--with-pic=1" \
    --command-flag "--with-parmetis=1" \
    --command-flag "--with-parmetis-dir=$(pack_get --install-prefix parmetis)" \
    --command-flag "--with-metis=1" \
    --command-flag "--with-metis-dir=$(pack_get --install-prefix parmetis)" \
    --command-flag "--with-superlu_dist=1" \
    --command-flag "--with-superlu_dist-dir=$(pack_get --install-prefix superlu)" \
    --command-flag "--with-hwloc=1" \
    --command-flag "--with-hwloc-dir=$(pack_get --install-prefix hwloc)" \
    --command-flag "--with-mumps=1" \
    --command-flag "--with-mumps-dir=$(pack_get --install-prefix mumps)" \
    --command-flag "--with-fftw=1" \
    --command-flag "--with-fftw-dir=$(pack_get --install-prefix fftw[3])" \
    --command-flag "--with-cholmod=1" \
    --command-flag "--with-cholmod-dir=$(pack_get --install-prefix cholmod)" \
    --command-flag "--with-netcdf=1" \
    --command-flag "--with-netcdf-dir=$(pack_get --install-prefix netcdf)" \
    --command-flag "--with-hdf5=1" \
    --command-flag "--with-hdf5-dir=$(pack_get --install-prefix hdf5)" \
    --command-flag "--with-umfpack=1" \
    --command-flag "--with-umfpack-dir=$(pack_get --install-prefix umfpack)" $tmp

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"