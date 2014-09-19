add_package http://www.grycap.upv.es/slepc/download/distrib/slepc-3.5.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libslepc.so

pack_set --module-requirement petsc \
    --module-requirement parpack

tmp_ld="$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))"
tmp_lib=

if $(is_c intel) ; then
    tmp_lib="-lmkl_blacs_openmpi_lp64 -mkl=cluster"

else

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp_ld="$tmp_ld $(list --LDFLAGS --Wlrpath atlas)"
	tmp_lib="-llapack -lf77blas -lcblas -latlas"

    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp_ld="$tmp_ld $(list --LDFLAGS --Wlrpath openblas)"
	tmp_lib="-llapack -lopenblas"

    else
	pack_set --module-requirement blas
	tmp_ld="$tmp_ld $(list --LDFLAGS --Wlrpath blas)"
	tmp_lib="-llapack -lblas"

    fi

fi

pack_set --command "CC='$MPICC' CFLAGS='$CFLAGS'" \
    --command-flag "CXX='$MPICXX' CXXFLAGS='$CFLAGS'" \
    --command-flag "FC='$MPIF90' FCFLAGS='$FCFLAGS'" \
    --command-flag "F77='$MPIF77' FFLAGS='$FFLAGS'" \
    --command-flag "LDFLAGS='$tmp_ld'" \
    --command-flag "LIBS='$tmp_ld $tmp_lib'" \
    --command-flag "AR=$AR" \
    --command-flag "RANLIB=ranlib" \
    --command-flag "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-arpack" \
    --command-flag "--with-arpack-dir=$(pack_get --library-path parpack)" \
    --command-flag "--with-arpack-flags='-lparpack -larpack'"

# Set the arch of the build (sets the directory...)
# (pre 3.5 PETSC_ARCH=arch-installed-petsc is needed)
pack_set --command "make SLEPC_DIR=\$(pwd)"

pack_set --command "make testexamples"
pack_set --command "make testfortran"

pack_set --command "make install"

# Unset architecture...
pack_set --command "unset PETSC_ARCH"
pack_set --command "unset SLEPC_DIR"

# This tests the installation (i.e. linking)
pack_set --command "make SLEPC_DIR=$(pack_get --install-prefix) test > tmp.test 2>&1"
pack_set_mv_test tmp.test

pack_set --module-opt "--set-ENV SLEPC_DIR=$(pack_get --install-prefix)"

# Clean up the unused module
pack_set --command "rm -rf $(pack_get --library-path)/modules"
