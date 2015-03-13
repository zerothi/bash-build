v=3.2.0
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

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp=
	    [ "x$la" == "xatlas" ] && \
		tmp=" -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    tmp_flags="--with-blas='${tmp:1}' --with-lapack='-llapack ${tmp:1}'"
	    break
	fi
    done

fi

pack_set --command "./configure" \
    --command-flag "F77='$FC'" \
    --command-flag "FFLAGS='$FCFLAGS'" \
    --command-flag "MPIF77='$MPIFC'" \
    --command-flag "--enable-mpi $tmp_flags" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make"
if ! $(is_host eris) ; then
	pack_set --command "make check > tmp.test 2>&1"
	pack_set_mv_test tmp.test
fi
pack_set --command "make install"
