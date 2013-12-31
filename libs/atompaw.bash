v=4.0.0.5
add_package http://users.wfu.edu/natalie/papers/pwpaw/atompaw-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement libxc

pack_set --install-query $(pack_get --install-prefix)/lib/libatompaw.a

tmp=
if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="$(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas"
    else
	pack_set --module-requirement blas --module-requirement lapack
	tmp="$(list --LDFLAGS --Wlrpath blas lapack) -llapack -lblas"
    fi

elif $(is_c intel) ; then
    tmp="$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64"

fi

pack_set --command "./configure" \
    --command-flag "--with-libxc-incs=$(pack_get --install-prefix libxc)/include" \
    --command-flag "--with-libxc-libs=$(pack_get --install-prefix libxc)/lib" \
    --command-flag "--with-linalg-libs='$tmp'" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
