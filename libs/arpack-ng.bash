v=3.2.0
add_package \
    --archive arpack-ng-$v.tar.gz \
    https://github.com/opencollab/arpack-ng/archive/$v.tar.gz

pack_set -s $IS_MODULE

# Required as the version has just been set
pack_set --install-query $(pack_get --LD)/libparpack.a

pack_set --module-requirement mpi

tmp_flags=""
if $(is_c intel) ; then
    tmp_flags="--with-blas='-mkl=sequential'"
    tmp_flags="$tmp_flags --with-lapack='-mkl=sequential'"

else

    for la in $(pack_choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    [[ "x$la" == "xatlas" ]] && \
		tmp=" -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    tmp_flags="--with-blas='${tmp:1}' --with-lapack='-llapack ${tmp:1}'"
	    break
	fi
    done

fi

pack_cmd "./configure" \
	 "F77='$FC'" \
	 "FFLAGS='$FCFLAGS'" \
	 "MPIF77='$MPIFC'" \
	 "--enable-mpi $tmp_flags" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make"
pack_cmd "make install"
