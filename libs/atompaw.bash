v=4.2.0.2
add_package http://users.wfu.edu/natalie/papers/pwpaw/atompaw-$v.tar.gz

pack_set -s $IS_MODULE

pack_set -module-requirement libxc

pack_set -install-query $(pack_get -prefix)/bin/atompaw

tmp=
if $(is_c intel) ; then
    tmp="$MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la

    tmp="$(list -LD-rp +$la) $(pack_get -lib $la)"
fi

pack_cmd "./configure" \
	 --enable-libxc \
	 "--with-libxc-prefix=$(pack_get -prefix libxc)" \
	 "--with-linalg-libs='$tmp'" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > atompaw.test 2>&1"
pack_cmd "make install"
pack_store atompaw.test

