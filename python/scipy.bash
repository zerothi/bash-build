v=1.10.1
add_package https://github.com/scipy/scipy/releases/download/v$v/scipy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/scipy

pack_set -build-mod-req cython
pack_set -build-mod-req pybind11
pack_set -build-mod-req pythran
if [[ $(pack_installed swig) -eq 1 ]]; then
    pack_set -build-mod-req swig
fi

pack_set -module-requirement numpy

# Ensure directory exists (for writing)
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"

# The later LAPACK versions have gegv routines deprecated and replaced by ggev
# However, ggev routines are already existing.
if [[ $(vrs_cmp $v 0.16.0) -eq 0 ]]; then
    if $(is_c gnu) ; then
	pack_cmd "pushd scipy/linalg"
	pack_cmd "sed -i '/[sdcz]gegs/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]gelsx/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]geqpf/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]ggsvd/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]ggsvp/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]lahrd/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]latzm/d' cython_lapack_signatures.txt"
	pack_cmd "sed -i '/[sdcz]tzrqf/d' cython_lapack_signatures.txt"
	pack_cmd "$(get_parent_exec) _cython_wrapper_generators.py"
	pack_cmd "popd"
	pack_cmd "$(get_parent_exec) tools/cythonize.py"
    fi
fi

pack_cmd "unset LDFLAGS"
# Fix for GNU compilers
# See github issue #8680
if [[ $(vrs_cmp $v 1.2.0) -lt 0 ]]; then
    pack_cmd "sed -i 's/\([[:space:]]*\)\(.*extra_link_args.*\)/\1ext.extra_link_args = \[arg for arg in ext.extra_link_args if not \"version-script\" in arg\]\n\1\2/' setup.py"
fi

pack_cmd "NPY_LAPACK_ORDER=$npy_lapack_order NPY_BLAS_ORDER=$npy_blas_order $_pip_cmd . --prefix=$(pack_get -prefix)"


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

