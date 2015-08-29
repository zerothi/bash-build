# Install gsl
add_package ftp://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libgsl.a

# Install commands that it should run
if $(is_c intel) ; then
    pack_cmd "../configure" \
	     "LIBS='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64 -lmkl_blas95_lp64'" \
	     "LDFLAGS='$MKL_LIB'" \
	     "--prefix $(pack_get --prefix)"

else

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp="$(list --LD-rp $la) -llapack"
	    [[ "x$la" == "xatlas" ]] && \
		tmp="$tmp -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    break
	fi
    done

    pack_cmd "../configure" \
	     "LIBS='-lm $tmp'" \
	     "--prefix $(pack_get --prefix)"
fi

# Make commands
pack_cmd "make $(get_make_parallel)"
if ! $(is_c intel) ; then
    pack_cmd "make check > tmp.test 2>&1"
fi
pack_cmd "make install"
if ! $(is_c intel) ; then
    pack_set_mv_test tmp.test
fi


