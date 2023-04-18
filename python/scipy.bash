v=1.10.1
add_package https://github.com/scipy/scipy/releases/download/v$v/scipy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/scipy

pack_set -build-mod-req meson
pack_set -build-mod-req cython
pack_set -build-mod-req pybind11
pack_set -build-mod-req pythran
if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_set -build-mod-req swig
fi
pack_set -module-requirement numpy

# Ensure directory exists (for writing)
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"

pack_cmd "unset LDFLAGS"

#bl=$(pack_choice -i linalg)
#la=lapack-$bl
#pack_set -mod-req $bl
#pack_cmd "BLAS='$(pack_get -LD $bl) $(pack_get -lib[omp] $bl)' LAPACK='$(pack_get -LD $la) $(pack_get -lib[omp] $la)' meson setup builddir $(list -prefix '--libdir=' -c 'pack_get -LD ' $la $bl)" 
#pack_cmd "meson install -C builddir" 
#pack_cmd "NPY_LAPACK_ORDER=$npy_lapack_order NPY_BLAS_ORDER=$npy_blas_order $_pip_cmd . --prefix=$(pack_get -prefix)"
pack_cmd "NPY_LAPACK_ORDER=$npy_lapack_order NPY_BLAS_ORDER=$npy_blas_order $(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"

if ! $(is_c intel) ; then
    add_test_package scipy.test
    pack_cmd "unset LDFLAGS"
    if [[ $(vrs_cmp $v 1.0.0) -ge 0 ]]; then
	pack_cmd "OMP_NUM_THREADS=$NPROCS pytest --pyargs scipy > $TEST_OUT 2>&1 || echo forced"
    else
	pack_cmd "OMP_NUM_THREADS=$NPROCS nosetests --exe scipy > $TEST_OUT 2>&1 || echo forced"
    fi
    pack_store $TEST_OUT
fi

