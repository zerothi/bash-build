add_package \
    --directory arpack-ng-3.1.4 \
    http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_3.1.4.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --install-prefix)/lib/libparpack.a

pack_set --module-requirement openmpi

tmp_flags=""
if $(is_c intel) ; then
    tmp_flags="--with-blas='-mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='-mkl=sequential'"

else
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp_flags="--with-blas='-lf77blas -lcblas -latlas'"
	tmp_flags="$tmp_flags --with-lapack='-llapack_atlas -lf77blas -lcblas -latlas'"

    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	tmp_flags="--with-blas='-lblas'"
	tmp_flags="$tmp_flags --with-lapack='-llapack'"

    fi
fi

pack_set --command "./configure" \
    --command-flag "F77='$FC'" \
    --command-flag "FFLAGS='$FCFLAGS'" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "CC='$CC'" \
    --command-flag "CFLAGS='$CFLAGS'" \
    --command-flag "MPIF77='$MPIFC'" \
    --command-flag "--enable-mpi $tmp_flags" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_set --command "make"
pack_set --command "make install"
