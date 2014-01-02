add_package http://www.grycap.upv.es/slepc/download/distrib/slepc-3.4.3.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libslepc.a

pack_set --module-requirement petsc \
    --module-requirement parpack

pack_set --command "export PETSC_DIR=$(pack_get --install-prefix petsc)"

tmp_ld="$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))"
tmp_lib=

if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ]; then
	tmp_ld="$tmp_ld $(list --LDFLAGS --Wlrpath atlas)"
	tmp_lib="-lf77blas -lcblas -latlas"
    else
	tmp_ld="$tmp_ld $(list --LDFLAGS --Wlrpath lapack blas)"
	tmp_lib="-llapack -lblas"
    fi
elif $(is_c intel) ; then
    tmp_lib="-mkl=sequential"

fi

pack_set --command "CC=$MPICC CFLAGS='$CFLAGS $tmp_ld'" \
    --command-flag "CXX=$MPICXX CXXFLAGS='$CFLAGS $tmp_ld'" \
    --command-flag "FC=$MPIF90 FCFLAGS='$FCFLAGS $tmp_ld'" \
    --command-flag "F77=$MPIF77 FFLAGS='$FFLAGS $tmp_ld'" \
    --command-flag "LDFLAGS='$tmp_ld'" \
    --command-flag "LIBS='$tmp_ld $tmp_lib'" \
    --command-flag "AR=$AR" \
    --command-flag "RANLIB=ranlib" \
    --command-flag "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-arpack" \
    --command-flag "--with-arpack-dir=$(pack_get --install-prefix parpack)/lib" \
    --command-flag "--with-arpack-flags='-lparpack -larpack $tmp_lib'"

# Set the arch of the build (sets the directory...)
pack_set --command "export PETSC_ARCH=arch-installed-petsc"
pack_set --command "export SLEPC_DIR=\$(pwd)"
pack_set --command "make"

pack_set --command "make install"

pack_set --command "make test"
pack_set --command "make testexamples"
pack_set --command "make testfortran"

pack_set --command "unset PETSC_DIR"
pack_set --command "unset PETSC_ARCH"
pack_set --command "unset SLEPC_DIR"

