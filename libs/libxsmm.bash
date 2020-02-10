v=1.14
add_package -archive libxsmm-$v.tar.gz \
	    https://github.com/hfp/libxsmm/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libxsmm.a
pack_set -lib -lxsmm

tmp=
if $(is_c intel) ; then
    noop
    
else
    blas=$(pack_choice -i linalg)
    pack_set -module-requirement $blas

    tmp="BLAS=$blas BLAS_LDFLAGS='$(list -LD-rp +$blas) $(pack_get -lib $blas)'"
fi

pack_cmd "make $(get_make_parallel) $tmp"
pack_cmd "make $tmp tests > xsmm.test 2>&1"
pack_cmd "make $tmp install PREFIX=$(pack_get -prefix)"
pack_store xsmm.test
