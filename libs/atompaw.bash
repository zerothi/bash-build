v=4.0.0.12
add_package http://users.wfu.edu/natalie/papers/pwpaw/atompaw-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement libxc

pack_set --install-query $(pack_get --LD)/libatompaw.a

tmp=
if $(is_c intel) ; then
    tmp="$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential"

else

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp="$(list --LD-rp $la) -llapack"
	    [ "x$la" == "xatlas" ] && \
		tmp="$tmp -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    break
	fi
    done
fi

pack_set --command "./configure" \
    --command-flag "--with-libxc-incs=$(pack_get --prefix libxc)/include" \
    --command-flag "--with-libxc-libs=$(pack_get --LD libxc)" \
    --command-flag "--with-linalg-libs='$tmp'" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

