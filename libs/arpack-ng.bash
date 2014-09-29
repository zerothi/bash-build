v=3.1.5
add_package \
    --directory arpack-ng-$v \
    http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_$v.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libparpack.a

pack_set --module-requirement openmpi

tmp_flags=""
if $(is_c intel) ; then
    tmp_flags="--with-blas='-mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='-mkl=sequential'"

else
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp_flags="--with-blas='-lf77blas -lcblas -latlas'"
	tmp_flags="$tmp_flags --with-lapack='-llapack -lf77blas -lcblas -latlas'"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp_flags="--with-blas='-lopenblas' --with-lapack='-llapack'"
    else
	pack_set --module-requirement blas
	tmp_flags="--with-blas='-lblas'"
	tmp_flags="$tmp_flags --with-lapack='-llapack'"
    fi
fi

pack_set --command "./configure" \
    --command-flag "F77='$FC'" \
    --command-flag "FFLAGS='$FCFLAGS'" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath $(pack_get --mod-req))'" \
    --command-flag "CC='$CC'" \
    --command-flag "CFLAGS='$CFLAGS'" \
    --command-flag "MPIF77='$MPIFC'" \
    --command-flag "--enable-mpi $tmp_flags" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test
